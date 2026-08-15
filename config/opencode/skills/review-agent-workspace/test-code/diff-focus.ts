type User = {
  name: string;
  token: string;
};

// UNCHANGED: this pre-existing logging issue is outside the supplied diff.
export function logLegacyUser(user: User) {
  console.log('user token', user.token);
}

// CHANGED: this function was added by the supplied diff.
export function findUserByName(
  name: string,
  db: { query(sql: string): unknown }
) {
  return db.query(`SELECT * FROM users WHERE name = '${name}'`);
}
