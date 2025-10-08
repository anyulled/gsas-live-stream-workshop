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
                description "A web-based user interface for users to watch live streams and interact with the platform"
                technology "Next.js"
            }

            streamService = container "Live Stream" "A live video stream" {
                liveStreamProcessor = component "Video Stream Component" "A component for streaming live video" {
                }
            }

            videoOnDemandService = container "Video Ingestion Service" "A service for ingesting live video streams from streamers" {
                videoIngestionComponent = component "Video Ingestion Component" "A component for ingesting live video streams from streamers" {

                }
                videoChunksProcessor = component "Video Chunks Processor" "A component for processing video chunks" {

                }
                vodDb = component "Video On Demand Database" "A database for storing video on demand content" {
                    tags Database
                }

                videoIngestionComponent -> videoChunksProcessor "processes video chunks"
                videoChunksProcessor -> vodDb "stores video metadata"
            }

            chatService = container "Chat Service" "A chat application for users to communicate with each other" {
                chatComponent = component "Chat Component" "A chat component for users to communicate with each other" {
                }
                chatDb = component "Chat Database" "A database for storing chat messages" {
                    tags Database
                }
                chatComponent -> chatDb "stores chat messages"
            }

            paymentsService = container "Payments Service" "A payment processing system for streamers to receive donations and tips" {
                paymentComponent = component "Payment Component" "A component for processing payments" java spring {

                }
                paymentsDb = component "Payments Database" "A database for storing payment information" postgres {
                    tags Database
                }
                paymentComponent -> paymentsDb "stores payment information"
            }

            storageService = container "Storage Service" "A storage system for storing live streams chunks" {

            }

            videoChunksProcessor -> storageService "stores video chunks"

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

                userBackend -> authenticationAdapter "uses for authentication"
                authenticationAdapter -> userBackend "provides authentication services"
                userBackend -> userDb "read/writes user data"
            }
        }

        user -> webUI "interacts with"
        streamer -> webUI "broadcasts music sessions"
        webUI -> liveStreamProcessor "Obtain streaming sessions"
        webUI -> videoOnDemandService "Get videos on demand"
        webUI -> chatComponent "Send and receive messages"
        webUI -> paymentComponent "Process payments"
        webUI -> userBackend "User-related operations"

        liveStreamProcessor -> storageService "Stores session videos"

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

        paymentComponent -> paypalService "Process payments"
        paymentComponent -> stripeService "Process payments"

        auth0 = softwareSystem "Auth0" "A user authentication and authorization service" {
            tags external
            autho0Service = container "Auth0" "A user authentication and authorization service" {
                tags external
            }
        }

        authenticationAdapter -> autho0Service "User authentication and authorization"

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
                        userInstance -> cdn "Serves media"

                        deploymentNode "EC2 - Web UI" {
                            tags "Amazon Web Services - EC2"
                            webInstance = containerInstance webUI
                        }

                        globalAccelerator -> webInstance "directing traffic to the nearest application endpoint"
                        webInstance -> apiGatewayInfra "Access backend services"
                        webInstance -> usersDatabase "Reads User Data"

                        deploymentNode "EC2 - Stream Service" {
                            tags "Amazon Web Services - EC2"
                            streamInstance = containerInstance streamService
                        }
                        streamInstance -> s3 "Writes Videos"
                        streamInstance -> ivs "Reads Video Streams"

                        deploymentNode "EC2 - VoD" {
                            tags "Amazon Web Services - EC2"
                            vodInstance = containerInstance videoOnDemandService
                        }

                        vodInstance -> vodDatabase "Reads VoD Data"
                        vodInstance -> s3ChunksBucket "Reads Videos"

                        deploymentNode "EC2 - Chat" {
                            tags "Amazon Web Services - EC2"
                            chatInstance = containerInstance chatService
                        }
                        chatInstance -> chatDatabase "Reads Chat Data"
                        chatInstance -> rekognition "Analyzes Images"

                        deploymentNode "EC2 - Payment" {
                            tags "Amazon Web Services - EC2"
                            paymentInstance = containerInstance paymentsService
                        }
                        paymentInstance -> paymentsDatabase "Reads Payment Data"
                        paymentInstance -> fraudDetector "Checks for Fraud"


                        deploymentNode "EC2 - Storage" {
                            tags "Amazon Web Services - EC2"
                            storageInstance = containerInstance storageService
                        }

                        storageInstance -> s3 "Uses Storage"
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
            paymentInstance -> stripeInfra "Processes Payments"
            paymentInstance -> payPalInfra "Processes Payments"
            userInstance -> auth0Infra "Authenticates Users"
        }
    }

    views {
        theme default
        themes https://static.structurizr.com/themes/amazon-web-services-2023.01.31/theme.json
        themes https://static.structurizr.com/themes/amazon-web-services-2022.04.30/theme.json
        themes https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json

        branding {
            logo images/gsas_logo.png
        }

        styles {

            element "Container" {
                shape roundedbox
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
