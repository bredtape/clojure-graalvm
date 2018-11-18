FROM clojure:lein-2.8.1 as builder
WORKDIR /project
# Optimize caching of dependencies
COPY project.clj .
RUN lein deps
# Copy files
COPY resources resources/
COPY src src/
COPY test test/
# Create uberjar. The uberjar is assumed to match target/*-standalone.jar (as per default with Leiningen)
RUN lein uberjar


FROM findepi/graalvm:1.0.0-rc9-native as native
WORKDIR /project
COPY --from=builder /project/target/*-standalone.jar /project/app.jar
# Create completely standalone binary
RUN /graalvm/bin/native-image -jar /project/app.jar --no-server --static


# Copy resulting binary to new and empty image
FROM scratch
COPY --from=native /project/app /app
ENTRYPOINT ["/app"]
