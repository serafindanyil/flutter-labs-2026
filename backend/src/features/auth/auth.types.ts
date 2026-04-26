export interface AuthUser {
  uid: string;
  email?: string;
  name?: string;
}

export interface FirebaseAuthVerifier {
  verifyToken(token: string): Promise<AuthUser>;
}
