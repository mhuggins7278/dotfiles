return {
  cmd = { 'terraform-ls', 'serve' },
  filetypes = { 'terraform', 'tf', 'hcl' },
  root_markers = { '.terraform', '.git' },
  settings = {
    terraform = {
      validation = {
        enableEnhancedValidation = true,
      },
      experimentalFeatures = {
        validateOnSave = true,
        prefillRequiredFields = true,
      },
    },
  },
}
