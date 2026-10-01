export const jwtConstants = {
  accessSecret: process.env.JWT_ACCESS_SECRET || 'super_secret_access_key_change_me',
  refreshSecret: process.env.JWT_REFRESH_SECRET || 'super_secret_refresh_key_change_me',
  accessExpiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '15m',
  refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
};
