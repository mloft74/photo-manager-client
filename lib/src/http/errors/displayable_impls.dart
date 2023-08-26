Iterable<String> notOk(String reason) =>
    ['HTTP request failed; reason: $reason'];

const timedOut = ['Request timed out. Are you on the right network?'];

Iterable<String> unknownBody(String body) => [
      'HTTP response had an unknown body:',
      body,
    ];
