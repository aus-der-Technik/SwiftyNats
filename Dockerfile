FROM swift:4.0.3

WORKDIR /test
COPY . .

RUN mkdir -p /build/lib
RUN cp -R /usr/lib/swift/linux/* /build/lib
RUN swift build -c debug
