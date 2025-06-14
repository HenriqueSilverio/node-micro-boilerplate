import js from '@eslint/js'
import globals from 'globals'
import { defineConfig } from 'eslint/config'
import jest from 'eslint-plugin-jest'
import stylistic from '@stylistic/eslint-plugin'

export default defineConfig([
  { files: ['**/*.{js,mjs,cjs}'], plugins: { js }, extends: ['js/recommended'] },
  { files: ['**/*.{js,mjs,cjs}'], languageOptions: { globals: globals.node } },
  {
    files: ['**/*.spec.{js,mjs,cjs}', '**/*.test.{js,mjs,cjs}'],
    plugins: { jest },
    languageOptions: {
      globals: jest.environments.globals.globals,
    },
    ...jest.configs['flat/recommended'],
    ...jest.configs['flat/style'],
  },
  {
    files: [
      '**/*.{js,mjs,cjs}',
      '**/*.spec.{js,mjs,cjs}',
      '**/*.test.{js,mjs,cjs}',
    ],
    plugins: { '@stylistic': stylistic },
    ...stylistic.configs.recommended,
  },
])
