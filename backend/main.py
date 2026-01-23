from fastapi import FastAPI, Query, HTTPException
import requests

app = FastAPI(title="Prosty F1 Top 10")

BASE = "https://api.openf1.org/v1"


@app.get("/results")
def get_top10_results(
    race: str = Query(..., description="Np. Las Vegas Grand Prix, Monaco Grand Prix")
):
    try:
        # 1. Znajdź meeting_key
        meetings = requests.get(f"{BASE}/meetings?year=2025", timeout=10).json()
        
        meeting_key = None
        for m in meetings:
            if race.lower() in m.get("meeting_name", "").lower():
                meeting_key = m["meeting_key"]
                break
        
        if not meeting_key:
            raise HTTPException(404, f"Nie znaleziono wyścigu: {race}")

        # 2. Znajdź session_key dla Race
        sessions = requests.get(f"{BASE}/sessions?meeting_key={meeting_key}", timeout=10).json()
        
        session_key = None
        for s in sessions:
            if "race" in s.get("session_name", "").lower():
                session_key = s["session_key"]
                break
        
        if not session_key:
            raise HTTPException(404, "Brak sesji Race dla tego GP")

        # 3. Pobierz wszystkich kierowców raz (szybciej i bezpieczniej)
        drivers_resp = requests.get(f"{BASE}/drivers?session_key={session_key}", timeout=10)
        drivers_resp.raise_for_status()
        drivers = drivers_resp.json()
        driver_map = {d["driver_number"]: d for d in drivers}

        # 4. Pobierz wyniki i weź top 10
        results_resp = requests.get(f"{BASE}/session_result?session_key={session_key}", timeout=10)
        results_resp.raise_for_status()
        results = results_resp.json()

        top_results = sorted(
            [r for r in results if r.get("position") is not None],
            key=lambda x: x["position"]
        )[:10]

        # 5. Zbuduj odpowiedź
        output = []
        for r in top_results:
            driver = driver_map.get(r["driver_number"], {})
            output.append({
                "position": r.get("position"),
                "driver": driver.get("full_name", "???"),
                "team": driver.get("team_name", "N/A")
            })

        if not output:
            raise HTTPException(404, "Brak wyników dla tej sesji")

        return output

    except requests.exceptions.RequestException as e:
        raise HTTPException(503, f"Błąd połączenia z OpenF1 API: {str(e)}")
    except Exception as e:
        raise HTTPException(500, f"Coś poszło nie tak: {str(e)}")


@app.get("/health")
def health():
    return {"status": "ok"}