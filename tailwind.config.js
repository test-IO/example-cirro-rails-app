// See the Tailwind default theme values here:
// https://github.com/tailwindcss/tailwindcss/blob/master/stubs/defaultConfig.stub.js
const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  plugins: [
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/forms')({ strategy: 'class' }),
    require('@tailwindcss/line-clamp'),
    require('@tailwindcss/typography'),
  ],

  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.erb'
  ],

  // All the default values will be compiled unless they are overridden below
  theme: {
    // Extend (add to) the default theme in the `extend` key
    extend: {
      // Create your own at: https://javisperez.github.io/tailwindcolorshades
      colors: {
        backdrop: {
          100: "#ced8e4",
          200: "#9cb1c9",
          300: "#6b8bad",
          400: "#396492",
          500: "#083d77",
          600: "#06315f",
          700: "#052547",
          800: "#031830",
          900: "#020c18"
        },
        primary: {
          100: "#ced8e4",
          200: "#9cb1c9",
          300: "#6b8bad",
          400: "#396492",
          500: "#083d77",
          600: "#06315f",
          700: "#052547",
          800: "#031830",
          900: "#020c18"
        },
        secondary: {
          100: "#d6d4e8",
          200: "#adaad1",
          300: "#837fba",
          400: "#5a55a3",
          500: "#312a8c",
          600: "#272270",
          700: "#1d1954",
          800: "#141138",
          900: "#0a081c"
        },
        tertiary: {
          100: "#d6d7d6",
          200: "#adaead",
          300: "#858685",
          400: "#5c5d5c",
          500: "#333533",
          600: "#292a29",
          700: "#1f201f",
          800: "#141514",
          900: "#0a0b0a"
        },
        neutral: {
          100: "#d9e5eb",
          200: "#b3cbd7",
          300: "#8cb0c4",
          400: "#6696b0",
          500: "#407c9c",
          600: "#33637d",
          700: "#264a5e",
          800: "#1a323e",
          900: "#0d191f"
        },
        accent: {
          100: "#f9f2db",
          200: "#f3e5b7",
          300: "#ecd894",
          400: "#e6cb70",
          500: "#e0be4c",
          600: "#b3983d",
          700: "#86722e",
          800: "#5a4c1e",
          900: "#2d260f"
        },
        danger: colors.red,
        success: {
          100: "#e7f2d3",
          200: "#d0e4a7",
          300: "#b8d77b",
          400: "#a1c94f",
          500: "#89bc23",
          600: "#6e961c",
          700: "#527115",
          800: "#374b0e",
          900: "#1b2607"
        },
        "code-400": "#fefcf9",
        "code-600": "#3c455b",
        "public-primary": {
          100: "#d4ddfa",
          200: "#a9bbf6",
          300: "#7d99f1",
          400: "#5277ed",
          500: "#2755e8",
          600: "#1f44ba",
          700: "#17338b",
          800: "#10225d",
          900: "#08112e"
        },
        "public-hover": {
          100: "#dbe3fb",
          200: "#b8c7f7",
          300: "#94aaf3",
          400: "#718eef",
          500: "#4d72eb",
          600: "#3e5bbc",
          700: "#2e448d",
          800: "#1f2e5e",
          900: "#0f172f"
        },
        "public-bg": {
          100: "#ced1d5",
          200: "#9da2aa",
          300: "#6b7480",
          400: "#3a4555",
          500: "#09172b",
          600: "#071222",
          700: "#050e1a",
          800: "#040911",
          900: "#020509"
        },
        "public-highlight": {
          100: "#fde8d3",
          200: "#fbd1a6",
          300: "#f8bb7a",
          400: "#f6a44d",
          500: "#f48d21",
          600: "#c3711a",
          700: "#925514",
          800: "#62380d",
          900: "#311c07"
        },
        "public-gray": {
          100: "#e5e6e7",
          200: "#cbcdcf",
          300: "#b0b3b8",
          400: "#969aa0",
          500: "#7c8188",
          600: "#63676d",
          700: "#4a4d52",
          800: "#323436",
          900: "#191a1b"
        },
      },
      transitionProperty: {
        'height': 'height'
      },
      fontFamily: {
        sans: ['Mulish', 'Inter', ...defaultTheme.fontFamily.sans],
      },
    },
  },

  // Opt-in to TailwindCSS future changes
  future: {
  },
}
