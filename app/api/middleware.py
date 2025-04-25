import time
from prometheus_client import Counter, Histogram
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware

# Prometheus metrics
REQUEST_COUNT = Counter(
    'api_requests_total',
    'Total count of API requests',
    ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = Histogram(
    'api_request_latency_seconds',
    'Request latency in seconds',
    ['method', 'endpoint']
)

INFERENCE_LATENCY = Histogram(
    'model_inference_latency_seconds',
    'Model inference latency in seconds'
)


class PrometheusMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        """
        Middleware to collect metrics for each request

        Args:
            request: FastAPI request object
            call_next: Function to call the next middleware or route handler

        Returns:
            The response from the next middleware or route handler
        """
        method = request.method
        path = request.url.path

        # Start timer for request latency
        start_time = time.time()

        # Process request
        response = await call_next(request)

        # Record latency
        duration = time.time() - start_time
        REQUEST_LATENCY.labels(method=method, endpoint=path).observe(duration)

        # Record request count
        REQUEST_COUNT.labels(
            method=method,
            endpoint=path,
            status=response.status_code
        ).inc()

        return response