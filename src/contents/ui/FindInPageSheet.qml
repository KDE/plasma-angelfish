InputSheet {
    id: findSheet
    title: i18n("Find in page")
    placeholderText: i18n("Find...")
    description: i18n("Highlight text on the current website")
    onAccepted: currentWebView.findText(findSheet.text)
}
