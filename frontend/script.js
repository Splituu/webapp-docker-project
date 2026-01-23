const BACKEND_URL = "/results";

const select = document.getElementById("race-select");
const loading = document.getElementById("loading");
const errorDiv = document.getElementById("error");
const table = document.getElementById("results-table");
const tbody = document.getElementById("results-body");

select.addEventListener("change", async () => {
	const race = select.value.trim();

	tbody.innerHTML = "";
	table.style.display = "none";
	errorDiv.style.display = "none";
	errorDiv.textContent = "";
	loading.style.display = "none";

	if (!race) return;

	loading.style.display = "block";

	try {
		const response = await fetch(
			`${BACKEND_URL}?race=${encodeURIComponent(race)}`,
			{
				method: "GET",
				headers: { Accept: "application/json" },
			},
		);

		if (!response.ok) {
			if (response.status === 404) {
				throw new Error("Wyścig nie znaleziony lub brak wyników");
			}
			throw new Error(`Błąd serwera: ${response.status}`);
		}

		const data = await response.json();

		if (!Array.isArray(data) || data.length === 0) {
			throw new Error("Brak wyników dla wybranego wyścigu");
		}

		data.forEach(item => {
			const tr = document.createElement("tr");
			tr.innerHTML = `
        <td class="position">${item.position || "-"}</td>
        <td>${item.driver || "—"}</td>
        <td>${item.team || "—"}</td>
      `;
			tbody.appendChild(tr);
		});

		table.style.display = "table";
	} catch (err) {
		errorDiv.textContent = err.message;
		errorDiv.style.display = "block";
		console.error(err);
	} finally {
		loading.style.display = "none";
	}
});
