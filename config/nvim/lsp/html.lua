return {
  settings = {
    html = {
      format = {
        enable = true,
        wrapLineLength = 120,
        wrapAttributes = 'auto',
        templating = true,
        unformatted = 'wbr',
        contentUnformatted = 'pre,code,textarea',
        endWithNewline = false,
        preserveNewLines = true,
        maxPreserveNewLines = 2,
      },
      validate = {
        scripts = true,
        styles = true,
      },
      autoClosingTags = true,
      suggest = {
        html5 = true,
      },
      hover = {
        documentation = true,
        references = true,
      },
    },
  },
}
