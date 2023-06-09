FROM golang:alpine AS build
WORKDIR /
COPY go.* ./
RUN go mod download
COPY *.go ./
RUN go build -ldflags='-s -w'

FROM gcr.io/distroless/static
COPY --from=build /main /main
CMD ["/main"]