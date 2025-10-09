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
            }

            chatService = container "Chat Service" "A chat application for users to communicate with each other" {
                chatComponent = component "Chat Component" "A chat component for users to communicate with each other" {
                }
                chatDb = component "Chat Database" "A database for storing chat messages" {
                    tags Database
                }
            }

            paymentsService = container "Payments Service" "A payment processing system for streamers to receive donations and tips" {
                paymentComponent = component "Payment Component" "A component for processing payments" java spring {

                }
                paymentsDb = component "Payments Database" "A database for storing payment information" postgres {
                    tags Database
                }
            }

            storageService = container "Storage Service" "A storage system for storing live streams chunks" {
                tags "bucket"
            }

            userService = container "User Service" "A web-based user interface for users to interact with the platform" {
                userBackend = component "User Backend" {
                    description "A backend component for handling user-related operations like authentication, following and subscriptions"
                    technology "Java"
                }
                userDb = component "User Database" "A database for storing user information" {
                    tags Database
                }
            }
        }

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

        auth0 = softwareSystem "Auth0" "A user authentication and authorization service" {
            tags external
            auth0Service = container "Auth0" "A user authentication and authorization service" {
                tags external
            }
        }

        production = deploymentEnvironment "Production Environment" {

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
