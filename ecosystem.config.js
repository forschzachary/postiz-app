module.exports = {
  apps: [
    {
      name: 'backend',
      script: 'pnpm',
      args: 'start',
      cwd: './apps/backend',
      env: {
        PORT: 3000,
      },
    },
    {
      name: 'frontend',
      script: 'pnpm',
      args: 'start',
      cwd: './apps/frontend',
    },
    {
      name: 'orchestrator',
      script: 'pnpm',
      args: 'start',
      cwd: './apps/orchestrator',
    },
  ],
};
