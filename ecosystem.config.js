module.exports = {
  apps: [
    {
      name: 'backend',
      script: 'sh',
      args: 'start-backend.sh',
      cwd: '/app',
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
