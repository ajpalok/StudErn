import { Controller } from "@hotwired/stimulus"
import debounce from "lodash.debounce"

export default class extends Controller {
    static targets = ["input", "results"]
    connect() {
        // this.resultsTarget.classList.add("hidden")
        // this.inputTarget.addEventListener("input", this.searchCompany.bind(this))
        this.searchCompany = debounce(this.searchCompany.bind(this), 300)
    }

    async searchCompany() {
        const companyName = this.inputTarget.value.trim()
        if (companyName.length < 3) {
            this.resultsTarget.classList.add("hidden")
            return
        }

        this.resultsTarget.classList.remove("hidden")
        try {
            const response = await fetch(`/recruiter/account_complete`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content")
                },
                body: JSON.stringify({
                    type: "account_completing_company_search",
                    company_name: companyName
                })
            })
            // get the response from the server in text format
            // and parse it as JSON

            if (!response.ok) {
                throw new Error("Network response was not ok")
            }

            const data = await response.json()

            if (data?.companies?.length > 0 && data.message === "success") {
                this.resultsTarget.innerHTML = `
                    <tr class="text-accent-content/50">
                        <th class="border border-accent-content/50">Index</th>
                        <th class="border border-accent-content/50">Results for "${companyName}"</th>
                    </tr>
                ` // Reset the results with a header
                this.resultsTarget.innerHTML += data.companies.map((company, index) => `
                    <tr>
                        <td class="border border-accent-content/50">${index + 1}</td>
                        <td class="border border-accent-content/50">
                            <a href="/recruiter/account_complete/company/${company.id}" class="underline inline-flex items-center gap-1">
                                ${company.name}
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-link-45deg" viewBox="0 0 16 16">
                                    <path d="M4.715 6.542 3.343 7.914a3 3 0 1 0 4.243 4.243l1.828-1.829A3 3 0 0 0 8.586 5.5L8 6.086a1 1 0 0 0-.154.199 2 2 0 0 1 .861 3.337L6.88 11.45a2 2 0 1 1-2.83-2.83l.793-.792a4 4 0 0 1-.128-1.287z"/>
                                    <path d="M6.586 4.672A3 3 0 0 0 7.414 9.5l.775-.776a2 2 0 0 1-.896-3.346L9.12 3.55a2 2 0 1 1 2.83 2.83l-.793.792c.112.42.155.855.128 1.287l1.372-1.372a3 3 0 1 0-4.243-4.243z"/>
                                </svg>
                            </a>
                        </td>
                    </tr>
                    `)
            } else {
                this.resultsTarget.innerHTML = "<tr><td>No matching companies found.</td></tr>"
            }
        } catch (error) {
            this.resultsTarget.innerHTML = "<tr><td>Error fetching results</td></tr>"
        }
    }

}
