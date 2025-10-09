workspace {
    name "Live-stream platform for musicians"
    description "The software architecture of the StageCast platform."

    !adrs adrs
    !docs docs

    model {
        user = person "User" "Watches live streams and interacts with the platform" {
            tags viewer
        }
        streamer = person "Streamer" "Broadcasts live video streams" {
            tags streamer
        }

        liveStream = softwareSystem "Live Stream Platform" "A platform for musicians to broadcast and watch live video streams" {
            webUI = container "Web UI" {
                tags "website"
                description "A web-based user interface for users to watch live streams and interact with the platform"
                technology "Next.js"
            }

            streamService = container "Live Stream" "A live video stream" {
                liveStreamProcessor = component "Video Stream Component" "A component for streaming live video" {
                }
            }

            videoOnDemandService = container "Video on Demand Service" "A service for ingesting live video streams from streamers" {
                videoIngestionComponent = component "Video Ingestion Component" "A component for ingesting live video streams from streamers" {

                }
                videoChunksProcessor = component "Video Chunks Processor" "A component for processing video chunks" {

                }
                vodDb = component "Video On Demand Database" "A database for storing video on demand content" {
                    tags Database
                }

                videoIngestionComponent -> videoChunksProcessor "processes video chunks" "https" "http"
                videoChunksProcessor -> vodDb "stores video metadata" "jdbc" "jdbc"
            }

            chatService = container "Chat Service" "A chat application for users to communicate with each other" {
                chatComponent = component "Chat Component" "A chat component for users to communicate with each other" {
                }
                chatDb = component "Chat Database" "A database for storing chat messages" {
                    tags Database
                }
                chatComponent -> chatDb "stores chat messages" "jdbc" "jdbc"
            }

            paymentsService = container "Payments Service" "A payment processing system for streamers to receive donations and tips" {
                paymentComponent = component "Payment Component" "A component for processing payments" java spring {

                }
                paymentsDb = component "Payments Database" "A database for storing payment information" postgres {
                    tags Database
                }
                paymentComponent -> paymentsDb "stores payment information" "jdbc" "jdbc"
            }

            storageService = container "Storage Service" "A storage system for storing live streams chunks" {
                tags "bucket"
            }

            videoChunksProcessor -> storageService "stores video chunks" "https" "http"

            userService = container "User Service" "A web-based user interface for users to interact with the platform" {
                userBackend = component "User Backend" {
                    description "A backend component for handling user-related operations like authentication, following and subscriptions"
                    technology "Java"
                }
                userDb = component "User Database" "A database for storing user information" {
                    tags Database
                }
                authenticationAdapter = component "Authentication Adapter" "An adapter for integrating with external authentication services" {
                }

                userBackend -> authenticationAdapter "uses for authentication" "https" "http"
                authenticationAdapter -> userBackend "provides authentication services" "https" "http"
                userBackend -> userDb "read/writes user data" "jdbc" "jdbc"
            }
        }

        user -> webUI "interacts with" "https" "http"
        streamer -> webUI "broadcasts music sessions" "https" "http"
        webUI -> liveStreamProcessor "Ingest streaming sessions" "RTMP" "RTMP"
        webUI -> videoOnDemandService "Get videos on demand" "HLS" "HLS"
        webUI -> chatComponent "Send and receive messages" "https" "http"
        webUI -> paymentComponent "Process payments" "https" "http"
        webUI -> userBackend "User-related operations" "https" "http"
        chatService -> userService "Retrieves user information" "grpc" "grpc"
        paymentsService -> userService "Retrieves user information" "grpc" "grpc"
        streamService -> userService "Retrieves user information" "grpc" "grpc"
        streamService -> videoOnDemandService "Uses the video  chunks processor for splitting the session video in smaller chunks"

        liveStreamProcessor -> storageService "Stores session videos" "RTMP" "RTMP"

        paypal = softwareSystem "PayPal" "A payment gateway for processing payments" {
            tags external
            paypalService = container "PayPal" "A payment gateway for processing payments" {
                tags external
            }
        }

        stripe = softwareSystem "Stripe" "A payment gateway for processing payments" {
            tags external
            stripeService = container "Stripe" "A payment gateway for processing payments" {
                tags external
            }
        }

        paymentComponent -> paypalService "Process payments" "https" "http"
        paymentComponent -> stripeService "Process payments" "https" "http"

        auth0 = softwareSystem "Auth0" "A user authentication and authorization service" {
            tags external
            auth0Service = container "Auth0" "A user authentication and authorization service" {
                tags external
            }
        }

        authenticationAdapter -> auth0Service "User authentication and authorization" "https" "http"

        production = deploymentEnvironment "Production Environment" {
            serviceWest = deploymentGroup "Service instance 1"
            deploymentNode "Amazon Web Services" {
                tags "Amazon Web Services - Cloud Map"
                deploymentNode "VPC" {
                    tags "Amazon Web Services - Virtual private cloud VPC"

                    apiGatewayInfra = infrastructureNode "API Gateway" {
                        tags "Amazon Web Services - API Gateway"
                    }
                    cdn = infrastructureNode "AWS CDN" "Amazon CloudFront" {
                        tags "Amazon Web Services - CloudFront"
                    }
                    ivs = infrastructureNode "IVS" "Interactive Video Service" {
                        tags "Amazon Web Services - Interactive Video Service"
                    }
                    fraudDetector = infrastructureNode "Fraud Detector" "Amazon Rekognition" {
                        tags "Amazon Web Services - Fraud Detector"
                    }
                    rekognition = infrastructureNode "Rekognition" "spam filter system" {
                        tags "Amazon Web Services - Rekognition"
                    }
                    s3 = infrastructureNode "Storage" "AWS - S3" {
                        tags "Amazon Web Services - Simple Storage Service"
                    }
                    s3ChunksBucket = infrastructureNode "Storage - Chunks" "AWS - S3 chunks" {
                        tags "Amazon Web Services - Simple Storage Service"
                    }
                    globalAccelerator = infrastructureNode "AWS Global Accelerator" "ensures users connect to the closest region" {
                        tags "Amazon Web Services - Global Accelerator"
                    }

                    chatDatabase = infrastructureNode "Chat Database" "Amazon DynamoDB" {
                        tags "Amazon Web Services - DynamoDB"
                    }

                    vodDatabase = infrastructureNode "VoD Database" "Amazon DynamoDB" {
                        tags "Amazon Web Services - DynamoDB"
                    }

                    paymentsDatabase = infrastructureNode "Payments Database" "Amazon RDS" {
                        tags "Amazon Web Services - RDS"
                    }

                    usersDatabase = infrastructureNode "Users Database" "Amazon RDS" {
                        tags "Amazon Web Services - RDS"
                    }

                    deploymentNode "eu-west-2" {
                        description "AWS - Europe Zone"
                        technology "AWS"
                        tags "Amazon Web Services - Region"

                        deploymentNode "EC2 - User Service" {
                            tags "Amazon Web Services - EC2"
                            userInstance = containerInstance userService
                        }
                        userInstance -> cdn "Serves media" "https" "http"

                        deploymentNode "EC2 - Web UI" {
                            tags "Amazon Web Services - EC2"
                            webInstance = containerInstance webUI
                        }

                        globalAccelerator -> webInstance "directing traffic to the nearest application endpoint"
                        webInstance -> apiGatewayInfra "Access backend services" "https" "http"
                        userInstance -> usersDatabase "Reads User Data" "jdbc" "jdbc"

                        deploymentNode "EC2 - Stream Service" {
                            tags "Amazon Web Services - EC2"
                            streamInstance = containerInstance streamService
                        }
                        streamInstance -> s3 "Writes Videos" "https" "https"
                        streamInstance -> ivs "Stores Video Streams" "RTMP" "RTMP"

                        deploymentNode "EC2 - VoD" {
                            tags "Amazon Web Services - EC2"
                            vodInstance = containerInstance videoOnDemandService
                        }

                        vodInstance -> vodDatabase "Reads VoD Data" "jdbc" "jdbc"
                        vodInstance -> s3ChunksBucket "Reads Videos" "HLS" "HLS"

                        deploymentNode "EC2 - Chat" {
                            tags "Amazon Web Services - EC2"
                            chatInstance = containerInstance chatService
                        }
                        chatInstance -> chatDatabase "Reads Chat Data" "jdbc" "jdbc"
                        chatInstance -> rekognition "Spam filter" "https" "http"

                        deploymentNode "EC2 - Payment" {
                            tags "Amazon Web Services - EC2"
                            paymentInstance = containerInstance paymentsService
                        }
                        paymentInstance -> paymentsDatabase "Reads Payment Data" "jdbc" "jdbc"
                        paymentInstance -> fraudDetector "Checks for Fraud" "https" "http"


                        deploymentNode "EC2 - Storage" {
                            tags "Amazon Web Services - EC2"
                            storageInstance = containerInstance storageService
                        }

                        storageInstance -> s3 "Uses Storage" "https" "http"
                    }
                }
            }
            deploymentNode "External Services" {
                stripeInfra = infrastructureNode "Stripe API" {
                    description "Stripe SaaS payment API"
                    tags "external"
                }
                payPalInfra = infrastructureNode "PayPal API" {
                    description "PayPal SaaS payment API"
                    tags "external"
                }
                auth0Infra = infrastructureNode "Auth0 API" {
                    description "Auth0 SaaS authentication API"
                    tags "external"
                }
            }
            paymentInstance -> stripeInfra "Processes Payments" "https" "http"
            paymentInstance -> payPalInfra "Processes Payments" "https" "http"
            userInstance -> auth0Infra "Authenticates Users" "https" "http"
        }
    }

    views {
        theme default
        themes https://static.structurizr.com/themes/amazon-web-services-2023.01.31/theme.json
        themes https://static.structurizr.com/themes/amazon-web-services-2022.04.30/theme.json
        themes https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json

        systemLandscape liveStream {
            title "Landscape view of StageCast"
            include *
            autoLayout lr
        }

        systemContext liveStream {
            title "System context view of StageCast"
            include *
            autolayout lr
        }

        container liveStream {
            title "Container view of StageCast"
            include *
        }
        # Requirements
        # 1 & 6. Users should be able to watch live streams
        dynamic liveStream {
            title "Streamer Broadcast Session"
            streamer -> webUI "Uses thee Web UI to broadcast a session"
            webUI -> streamService "Uses the stream service to ingest the video"
            streamService -> videoOnDemandService "Uses the video  chunks processor for splitting the session video in smaller chunks"
            videoOnDemandService -> storageService "Stores de video in smaller chunks for enabling adaptive bitrate"
            autoLayout lr
        }
        # 2 & 6. Users should be able to watch live streams
        dynamic liveStream {
            title "User views a session"
            user -> webUI "Uses thee Web UI to choose a session"
            webUI -> streamService "Uses the stream service to watch the video"
            streamService -> videoOnDemandService "Uses the video  chunks processor for retrieving the session video in smaller chunks"
            videoOnDemandService -> storageService "REads de video in smaller chunks for enabling adaptive bitrate"
            autoLayout lr
        }
        # 3. Users should be able to chat in real-time
        dynamic liveStream {
            streamer -> webUI "Uses thee Web UI to broadcast a session"
            user -> webUI "Uses thee Web UI to join a session"
            webUI -> userService "Uses the user service to authenticate users"
            webUI -> chatService "The chat service enables messaging between users and streamers"
            autoLayout lr
        }
        # 4 & 5. Users should be able to follow and subscribe to streamers
        dynamic liveStream {
            streamer -> webUI "creates a streamer account"
            user -> webUI "Uses the Web UI susbcribe to streamers"
            webUI -> userService "Uses the user service to authenticate users"
            userService -> paymentsService "Users can donate and subscribe to premium levels"
            paymentsService -> paypal "Payment is done via Paypal"
            paymentsService -> stripe "Payment is done via Stripe"
            autoLayout lr
        }

        deployment * production {
            title "Production deployment with AWS"
            include *
        }

        branding {
            logo images/gsas_logo.png
        }

        styles {

            element "Container" {
                shape roundedbox
            }
            element "bucket" {
                shape Pipe
                background #D69813
            }
            element "Database" {
                shape cylinder
            }

            element "Group:Third-party" {
                border dotted
                color #AA0000
                background #BB0000
                opacity 75
            }

            element "external" {
                shape component
                color #FFFFFF
                background #000088
            }
            element "Database" {
                color #FFFFFF
                background #00aa00
            }
            element "speaker" {
                background #000000
                color #ffffff
            }

            element "viewer" {
                background #002454
                color #ffffff
            }
            element "streamer" {
                background #FF0000
                color #ffffff
            }
            element "Database" {
                shape cylinder
            }
            element "website" {
                shape WebBrowser
            }
            element "Ubuntu" {
                color #E95420
                background #E95420
                stroke #E95420
                icon "images/ubuntu-logo.jpeg"
            }
            relationship "gRPC" {
                color #000088
                style dotted
            }
        }
    }

}
