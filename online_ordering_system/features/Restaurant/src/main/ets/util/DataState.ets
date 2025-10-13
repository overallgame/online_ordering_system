export enum LoadStatus {
  Idle = 'idle',
  Loading = 'loading',
  Success = 'success',
  Error = 'error'
}

export interface DataState<T> {
  status: LoadStatus;
  data: T;
  error?: string;
  lastUpdated?: number; // epoch ms
}

export function idleState<T>(data: T): DataState<T> {
  return { status: LoadStatus.Idle, data };
}

export function loadingState<T>(prevData: T): DataState<T> {
  return { status: LoadStatus.Loading, data: prevData };
}

export function successState<T>(data: T): DataState<T> {
  return { status: LoadStatus.Success, data, lastUpdated: Date.now() };
}

export function errorState<T>(prevData: T, message: string): DataState<T> {
  return { status: LoadStatus.Error, data: prevData, error: message };
}


