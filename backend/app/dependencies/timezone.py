from fastapi import Request


def get_request_timezone(request: Request) -> str | None:
    timezone_name = request.headers.get("X-Timezone") or request.headers.get("Time-Zone")

    if not isinstance(timezone_name, str):
        return None

    normalized = timezone_name.strip()
    return normalized or None
