const path = require("path");

module.exports = {
  // Compact markdown tables (no cell padding/alignment).
  // Absolute-ish path via __dirname so it resolves no matter which file is
  // being formatted (Prettier resolves bare plugin names from the file's dir,
  // not the config's dir, so a bare name in a global config would not work).
  plugins: [
    path.join(__dirname, "node_modules", "prettier-plugin-compact-markdown-table", "src", "index.js"),
  ],
  overrides: [
    {
      files: ["*.json", "*.jsonc"],
      options: {
        printWidth: 140,
      },
    },
  ],
};
