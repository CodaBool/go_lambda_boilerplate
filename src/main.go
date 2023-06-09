package main

import (
	"context"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

func check(err error) {
	if err != nil {
		log.Fatal().Err(err).Msg("")
	}
}

func buildLogger(isProduction bool) {
	if isProduction {
		// has no timestamp and outputs json
		// by default all log levels are printed
		// changing fieldname to message makes filtering easier in AWS
		log.Logger = zerolog.New(os.Stderr).With().Logger()
		// zerolog.SetGlobalLevel(zerolog.InfoLevel)
		// https://github.com/rs/zerolog#error-logging
		zerolog.ErrorFieldName = "message"
		return
	}
	log.Logger = log.Output(zerolog.ConsoleWriter{
		Out:          os.Stderr,
		PartsExclude: []string{zerolog.TimestampFieldName},
		FormatCaller: func(i interface{}) string { return "" },
	}).Level(zerolog.DebugLevel).With().Caller().Logger()
	zerolog.SetGlobalLevel(zerolog.DebugLevel)
}

type Input struct {
	Start bool `json:"start"`
}

func main() {
	if os.Getenv("AWS_LAMBDA_FUNCTION_NAME") == "" {
		buildLogger(false)
		handle(nil, Input{Start: false})
	} else {
		buildLogger(true)
		lambda.Start(handle)
	}
}

func handle(ctx context.Context, input Input) (string, error) {
	log.Print("hello")
	log.Print(ctx, input)
	// cfg, err := config.LoadDefaultConfig(context.TODO())
	// check(err)
	// client := ec2.NewFromConfig(cfg)

	return "", nil
}
