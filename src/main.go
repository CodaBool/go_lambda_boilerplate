package main

import (
	"context"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/rs/zerolog"
)

var log zerolog.Logger

func check(err error) {
	if err != nil {
		log.Fatal().Err(err).Msg("")
	}
}

func buildLogger() {
	log = zerolog.New(os.Stderr).With().Logger()
	if os.Getenv("AWS_LAMBDA_FUNCTION_NAME") == "" {
		o := zerolog.ConsoleWriter{Out: os.Stdout, PartsExclude: []string{zerolog.TimestampFieldName}}
		log = zerolog.New(o).With().Logger()
	}
	zerolog.SetGlobalLevel(zerolog.TraceLevel)
	if os.Getenv("QUIET") != "" {
		zerolog.SetGlobalLevel(zerolog.InfoLevel)
	}
}

type Input struct {
	Start bool `json:"start"`
}

func main() {
	buildLogger()
	if os.Getenv("AWS_LAMBDA_FUNCTION_NAME") == "" {
		// write a test input for local development
		handle(context.TODO(), Input{Start: false})
	} else {
		lambda.Start(handle)
	}
}

func handle(ctx context.Context, input Input) (string, error) {
	log.Print("input", input)

	// cfg, err := config.LoadDefaultConfig(context.TODO())
	// check(err)
	// client := ec2.NewFromConfig(cfg)

	return "done", nil
}
