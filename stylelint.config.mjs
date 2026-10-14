export default {
  extends: ["stylelint-config-standard-scss"],
  rules: {
    // libsass (sassc-rails) cannot compile the modern notations of media queries and colors
    "alpha-value-notation": "number",
    "color-function-alias-notation": "with-alpha",
    "color-function-notation": "legacy",
    "media-feature-range-notation": "prefix",
    // Rails generates the ids of form fields in snake_case
    "selector-id-pattern": [
      "^[a-z][a-z0-9]*([-_][a-z0-9]+)*$",
      { message: (selector) => `Expected id selector "${selector}" to be kebab-case or snake_case` }
    ]
  }
};
