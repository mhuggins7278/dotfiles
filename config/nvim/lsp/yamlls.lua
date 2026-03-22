return {
  settings = {
    yaml = {
      schemaStore = {
        enable = true,
        url = 'https://www.schemastore.org/api/json/catalog.json',
      },
      schemas = require('schemastore').yaml.schemas(),
      format = {
        enable = true,
        singleQuote = false,
        bracketSpacing = true,
      },
      validate = true,
      hover = true,
      completion = true,
      customTags = {
        '!vault',
        '!encrypted/pkcs1-oaep scalar',
        '!reference sequence',
      },
    },
    redhat = {
      telemetry = {
        enabled = false,
      },
    },
  },
}
