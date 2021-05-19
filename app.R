library(shiny)
library(dplyr)
library(magrittr)
library(DT)

if(!exists("mi_atlas")){
  mi_atlas <- read.table("mi-atlas.tsv", header = TRUE, sep = "\t",
                         stringsAsFactors = FALSE, row.names = 1)
}

# Define UI
ui <- fluidPage(
  lang = "en", 
  title = "mi-atlas",
  fluidRow(column(width = 12, align = "center",
                  h1("An interactive and evolving microbial interactions catalog"))),
  fluidRow(
    column(
      imageOutput("logo"),
      align = "center", alt = "Logo of mi-atlas", width = 1),
    column(width = 8, offset = 1,
           fluidRow(
             column(width = 6,
                    h2("About", align = "center"),
                    p("Here is the list of interactions occuring between microorganisms that are documented",
                      "in the versioned catalog (see website).", "This classification is based on a framework",
                      "suggested by", a(href="https://doi.org/10.1093/femsle/fnz125",
                                        target = "_blank", rel = "noreferrer noopener",
                                        # open in new tab w/ protection
                                        "(Pacheco and Segrè, 2019)."), align = "left")),
             column(width = 6,
                    h2("How to explore", align = "center"),
                    p("Browse the list of microbial interactions below.",
                      "Upon selection of a row, details of the interaction will be displayed",
                      a(href = "#interaction-details", "below"),"the table."),
                    helpText("Details on the column names can be found",
                             a(href="https://github.com/cpauvert/mi-atlas/blob/main/README.md#attributes-of-microbial-interactions",
                               target = "_blank", rel = "noreferrer noopener",
                               # open in new tab w/ protection
                               "here."))
                    )),
           fluidRow(h2("List of the interactions", align = "center"), DT::dataTableOutput("table"))
    ),
    column(align = "center", width = 1, offset = 1,
      a(href="https://cpauvert.github.io/mi-atlas/framework.html",
        target = "_blank", rel = "noreferrer noopener",
        icon("book-open")), br(),
      a(href="https://cpauvert.github.io/mi-atlas/framework.html",
        target = "_blank", rel = "noreferrer noopener", "Framework"), br(),
      a(href="https://cpauvert.github.io/mi-atlas",
        target = "_blank", rel = "noreferrer noopener", icon("globe")), br(),
      a(href="https://cpauvert.github.io/mi-atlas",
        target = "_blank", rel = "noreferrer noopener", "Website"), br(),
      a(href="https://github.com/cpauvert/mi-atlas/blob/main/CONTRIBUTING.md",
        target = "_blank", rel = "noreferrer noopener", icon("github")), br(),
      a(href="https://github.com/cpauvert/mi-atlas/blob/main/CONTRIBUTING.md",
        target = "_blank", rel = "noreferrer noopener", "Contribute")
      )
  ),
  fluidRow(
    column(width = 8, offset = 2,
           h2("Details on the interaction", textOutput("int_no", inline = T),
              id="interaction-details", align = "center"),
           h3(textOutput("int_name"), align = "center")
           )
  )
)

# Define server logic
server <- function(input, output, session) {
  output$logo <- renderImage({
    list(src="docs/content/extra/logo.png",
         # align="left", width="155", height="179",
         align="left", width="77.5", height="89.5",
         alt = "Logo of mi-atlas")
  }, deleteFile = FALSE)
  preview_atlas <- reactive({
    mi_atlas %>% select(Interaction_name,
                        Participant_1, Participant_2, Participant_3)
  })
  output$table <- DT::renderDataTable(preview_atlas(),
                                      extensions = 'Responsive',
                                      selection = list(
                                        mode = 'single',
                                        selected = '7',
                                        target = 'row'),
                                      options = list(
                                        autoWidth = TRUE
                                        )
  )
  output$int_no <- renderText({
    paste0("#", input$table_rows_selected)
  })
  output$int_name <- renderText({
    preview_atlas()[ input$table_rows_selected, "Interaction_name"]
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

