export interface FirebaseConfig {
  projectId?: string;
  clientEmail?: string;
  privateKey?: string;
  serviceAccountJson?: string;
}

export interface AppConfig {
  port: number;
  host: string;
  nodeEnv: string;
  corsOrigin: string | boolean;
  databaseUrl: string;
  firebase: FirebaseConfig;
}
