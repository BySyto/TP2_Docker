FROM golang:1.27

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download
RUN go install github.com/air-verse/air@latest
COPY *.go ./
RUN go build
COPY ./public public

RUN CGO_ENABLED=0 GOOS=linux go build -o /guestbook
EXPOSE 8080
CMD ["air", "-c", ".air.toml"]
