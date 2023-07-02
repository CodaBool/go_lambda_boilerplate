package main

import (
	"context"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	pg "github.com/georgysavva/scany/v2/pgxscan"
	"github.com/jackc/pgx/v5/pgxpool"
	_ "github.com/joho/godotenv/autoload"
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

// the event input for the lambda
// Always capitalize exported props
type Input struct {
	Start bool `json:"start"`
}

func main() {
	buildLogger()
	if os.Getenv("AWS_LAMBDA_FUNCTION_NAME") == "" {
		// run locally
		handle(context.TODO(), Input{Start: false})
	} else {
		// run at AWS
		lambda.Start(handle)
	}
}

// always capitalize the first letter or the prop can't be accessed
type TrendingGithub struct {
	Name        string
	FullName    string
	Stars       int64
	Description string
	UpdatedAt   time.Time
}

func handle(ctx context.Context, input Input) (string, error) {
	log.Print("input = ", input)
	// use connection pooling for serverless designs
	db, err := pgxpool.New(context.Background(), os.Getenv("PG_URI"))
	check(err)
	var gh []*TrendingGithub
	// the pg scan package can easily map the sql output into the struct
	//   If you want a ORM, GORM is a popular Go solution
	//   which has all the ORM nice features like schema migrations
	err = pg.Select(context.Background(), db, &gh, `SELECT * FROM trending_githubs LIMIT 25`)
	check(err)
	log.Print("selected rows ", len(gh))

	for _, repo := range gh {
		log.Print(repo.Name)
	}

	// example usage of the aws sdk
	// you will need to update the lambda role to have the permissions
	// to access the specific aws service (e.g. s3:* Allow policy)

	// cfg, err := config.LoadDefaultConfig(context.TODO())
	// check(err)
	// client := ec2.NewFromConfig(cfg)

	return "done", nil
}
