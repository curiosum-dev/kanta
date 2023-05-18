// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require("tailwindcss/plugin");
const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  darkMode: "class",
  content: ["./js/**/*.js", "../lib/*_web.ex", "../lib/*_web/**/*.*ex"],
  safelist: [
    {
      pattern: /.*text-.*/,
    },
    {
      pattern: /.*bg-.*/,
    },
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["KoHo", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        base: {
          light: "#fbf5ff",
          dark: "#343434",
        },
        content: {
          light: "#f5f6f3",
          dark: "#141414",
        },
        primary: {
          light: "#9b66e1",
          DEFAULT: "#7E37D8",
          dark: "#6f28cc",
        },
        accent: {
          light: "#f69365",
          DEFAULT: "f36d2e",
          dark: "#f25d18",
        },
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", ["&.phx-no-feedback", ".phx-no-feedback &"])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        "&.phx-click-loading",
        ".phx-click-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        "&.phx-submit-loading",
        ".phx-submit-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        "&.phx-change-loading",
        ".phx-change-loading &",
      ])
    ),
  ],
};
