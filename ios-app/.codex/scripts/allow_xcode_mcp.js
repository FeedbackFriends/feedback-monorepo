#!/usr/bin/env osascript -l JavaScript

function run() {
  const systemEvents = Application('System Events')
  const xcodeProcess = systemEvents.processes.byName('Xcode')

  let approvedCount = 0

  try {
    const windows = xcodeProcess.windows()
    for (const window of windows) {
      const staticTexts = window.staticTexts()
      for (const text of staticTexts) {
        if (text.value().includes('to access Xcode?')) {
          const buttons = window.buttons()
          for (const button of buttons) {
            if (button.name() === 'Allow') {
              button.click()
              approvedCount++
              break
            }
          }
        }
      }
    }
  } catch (error) {
    if (
      error.message.includes('Invalid index') ||
      error.message.includes("Can't get object")
    ) {
      return 'Xcode not running'
    }

    return 'Error: ' + error.message
  }

  return approvedCount > 0
    ? `Approved ${approvedCount} MCP connection(s)`
    : 'No pending MCP dialogs'
}
