vcl 4.0;

backend default {
    .host = "django";
    .port = "8000";
}

# For testing purposes
sub vcl_backend_response {
    set beresp.ttl = 1s;
}