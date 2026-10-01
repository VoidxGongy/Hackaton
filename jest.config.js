/** @type {import('@jest/types').Config} */
module.exports = {
  testEnvironment: 'node',
  rootDir: '.',
  testRegex: 'src/.*\\.spec\\.ts$',
  moduleFileExtensions: ['js', 'json', 'ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.spec.ts',
    '!src/main.ts',
  ],
  coverageDirectory: 'coverage',
  transform: {
    '^.+\\.(ts|js)$': '@swc/jest',
  },
  transformIgnorePatterns: [
    '/node_modules/(?!(@nestjs|@prisma|firebase-admin|reflect-metadata|rxjs|class-validator|class-transformer)/)',
  ],
  moduleNameMapper: {
    '^@prisma/client$': '<rootDir>/node_modules/@prisma/client',
  },
};
