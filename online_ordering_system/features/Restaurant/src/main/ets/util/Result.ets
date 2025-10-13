export type Result<T> = Success<T> | Failure;

export interface Success<T> {
  ok: true;
  data: T;
}

export interface Failure {
  ok: false;
  error: string;
}

export function ok<T>(data: T): Success<T> {
  return { ok: true, data };
}

export function err(message: string): Failure {
  return { ok: false, error: message };
}


