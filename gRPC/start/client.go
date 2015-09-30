package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"strconv"
	"time"
	"io"

	pb "./books"

	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

var (
	address = flag.String("address", "127.0.0.1:50051", "Address of service")
)

// GetClient attempts to dial the specified address flag and returns a service
// client and its underlying connection. If it is unable to make a connection,
// it dies.
func GetClient() (*grpc.ClientConn, pb.BookServiceClient) {
	conn, err := grpc.Dial(*address, grpc.WithTimeout(5*time.Second), grpc.WithInsecure())
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	return conn, pb.NewBookServiceClient(conn)
}

func main() {
	flag.Parse()
	ctx := context.Background()
	cmd, ok := commands[flag.Arg(0)]
	if !ok {
		usage()
	} else {
		cmd.do(ctx, flag.Args()[1:]...)
	}
}

func usage() {
	fmt.Println(`client.go is a command-line client for this codelab's gRPC service

Usage:
  client.go list                            List all books
  client.go insert <id> <title> <author>    Insert a book
  client.go get <id>                        Get a book by its ID
  client.go delete <id>                     Delete a book by its ID
  client.go watch                           Watch for inserted books`)
}

var commands = map[string]struct {
	name, desc string
	do         func(context.Context, ...string)
	usage      string
}{
	"get": {
		name:  "get",
		desc:  "Retrieves the indicated book",
		do:    doGet,
		usage: "client.go get <id>",
	},
	"list": {
		name:  "list",
		desc:  "Lists all books",
		do:    doList,
		usage: "client.go list",
	},
	"insert": {
		name:  "insert",
		desc:  "Inserts the provided book",
		do:    doInsert,
		usage: "client.go insert <id> <title> <author>",
	},
	"delete": {
		name:  "delete",
		desc:  "Deletes the indicated book",
		do:    doDelete,
		usage: "client.go delete <id>",
	},
	"watch": {
		name:  "watch",
		desc:  "Watches for inserted books",
		do:    doWatch,
		usage: "client.go watch",
	},
}

// printRespAsJson attempts to marshal the provided interface into its JSON
// representation, then prints to stdout.
func printRespAsJson(r interface{}) {
	b, err := json.MarshalIndent(r, "", "  ")
	if err != nil {
		log.Fatalf("printResp (%v): %v", r, err)
	}
	fmt.Println(string(b))
}

// doGet is a basic wrapper around the corresponding book service's RPC.
// It parses the provided arguments, calls the service, and prints the
// response. If any errors are encountered, it dies.
func doGet(ctx context.Context, args ...string) {
	if len(args) != 1 {
		log.Fatalf("usage: client.go get <id>")
	}
	id, err := strconv.ParseInt(args[0], 10, 64)
	if err != nil {
		log.Fatalf("Provided ID %v invalid: %v", args[0], err)
	}
	conn, client := GetClient()
	defer conn.Close()
	r, err := client.Get(ctx, &pb.BookIdRequest{int32(id)})
	if err != nil {
		log.Fatalf("Get book (%v): %v", id, err)
	}
	fmt.Println("Server response:")
	printRespAsJson(r)
}

// doDelete is a basic wrapper around the corresponding book service's RPC.
// It parses the provided arguments, calls the service, and prints the
// response. If any errors are encountered, it dies.
func doDelete(ctx context.Context, args ...string) {
	if len(args) != 1 {
		log.Fatalf("usage: client.go delete <id>")
	}
	id, err := strconv.ParseInt(args[0], 10, 64)
	if err != nil {
		log.Fatalf("Provided ID %v invalid: %v", args[0], err)
	}
	conn, client := GetClient()
	defer conn.Close()
	r, err := client.Delete(ctx, &pb.BookIdRequest{int32(id)})
	if err != nil {
		log.Fatalf("Get book (%v): %v", id, err)
	}
	fmt.Println("Server response:")
	printRespAsJson(r)
}

// doList is a basic wrapper around the corresponding book service's RPC.
// It parses the provided arguments, calls the service, and prints the
// response. If any errors are encountered, it dies.
func doList(ctx context.Context, args ...string) {
	conn, client := GetClient()
	defer conn.Close()
	rs, err := client.List(ctx, &pb.Empty{})
	if err != nil {
		log.Fatalf("List books: %v", err)
	}
	fmt.Printf("Server sent %v book(s).\n", len(rs.GetBooks()))
	printRespAsJson(rs)
}

// doInsert is a basic wrapper around the corresponding book service's RPC.
// It parses the provided arguments, calls the service, and prints the
// response. If any errors are encountered, it dies.
func doInsert(ctx context.Context, args ...string) {
	if len(args) != 3 {
		log.Fatalf("usage client.go insert <id> <title> <author>")
	}
	id, err := strconv.ParseInt(args[0], 10, 64)
	if err != nil {
		log.Fatalf("Provided ID %v invalid: %v", args[0], err)
	}
	book := &pb.Book{
		Id:     int32(id),
		Title:  args[1],
		Author: args[2],
	}
	conn, client := GetClient()
	defer conn.Close()
	r, err := client.Insert(ctx, book)
	if err != nil {
		log.Fatalf("Insert book (%v): %v", book, err)
	}
	fmt.Println("Server response:")
	printRespAsJson(r)
}

// doWatch is a basic wrapper around the corresponding book service's RPC.
// It parses the provided arguments, calls the service, and prints the
// response. If any errors are encountered, it dies.
func doWatch(ctx context.Context, args ...string) {
	conn, client := GetClient()
	defer conn.Close()
	stream, err := client.Watch(ctx, &pb.Empty{})
	if err != nil {
		log.Fatalf("Watch books: %v", err)
	}
	for {
		book, err := stream.Recv()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatalf("Watch books stream: %v", err)
		}
		fmt.Println("Server stream data received:")
		printRespAsJson(book)
	}
}
