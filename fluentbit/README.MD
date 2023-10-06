#### Docker driver log

logging:
  driver: fluentd
  options:
    fluentd-address: localhost:24224
    fluentd-async: "true"