library(shiny)
library(bslib)
library(dplyr)
library(magrittr)
library(DT)

# Resources to be loaded
if(!exists("mi_atlas")){
  mi_atlas <- read.table("mi-atlas.tsv", header = TRUE, sep = "\t",
                         stringsAsFactors = FALSE, row.names = 1)
}

if(!exists("decoding")){
  decoding <- list(
    "binary" = setNames(c("No", "Yes", "Unknown"), c("0","1","Unknown")),
    "ternary" = setNames(c("Neutral", "Beneficial", "Unknown","Detrimental"),
                         c("0","1","Unknown","-1"))
  )
}

if(!exists("questions")){
  questions <- list(
    "Participant" = "What is the participant name?",
    "Domain" = "From which domain of life?",
    "Taxonomic_resolution" = "What is the taxonomic resolution of the interaction?",
    "Specificity" = "Is the mechanism of interaction specific?",
    "Cost" = "Is participation costly?",
    "Outcome" = "What is the outcome?"
  )
}

# Define UI
ui <- fluidPage(
  lang = "en", 
  title = "mi-atlas",
  theme = bs_theme( # Based on m.css dark theme
    bg = "#22272e",
    fg = "#ffffff",
    primary = "#5b9dd9",#"#a5c9ea",
    base_font = font_google("Source Sans Pro"),
    code_font = font_google("Source Code Pro")
  ),
  fluidRow(column(width = 12, align = "center",
                  h1("An interactive and evolving microbial interactions catalog"))),
  fluidRow(
    column(
      imageOutput("logo"),
      align = "center", alt = "Logo of mi-atlas", width = 1),
    column(width = 8, offset = 1,
           fluidRow(
             column(width = 6,
                    h2("About mi-atlas", align = "center"),
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
           fluidRow(h2("List of microbial interactions", align = "center"), DT::dataTableOutput("table"))
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
           h3("Interaction name:", textOutput("int_name", inline = T), align = "center"),
           h4("Taxonomy and specificity"),
           tags$ul(
             tags$li(textOutput("int_tax")),
             tags$li(textOutput("int_specificity"))
           ),
           h4("Interaction participants"),
           column(width = 10, offset = 1, tableOutput("participant_table")),
           h4("Interaction features"),
           column(width = 3, tableOutput("dependencies_table")),
           column(width = 3),
           column(width = 3),
           column(width = 3)
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
                        Participant_1,
                        Participant_2,
                        Participant_3)
  })
  output$table <- DT::renderDataTable(preview_atlas(),
                                      extensions = 'Responsive',
                                      selection = list(
                                        mode = 'single',
                                        selected = '7',
                                        target = 'row'),
                                      options = list(autoWidth = TRUE),
                                      style = "bootstrap4"
  )
  selected_atlas <- reactive({
    # Extraction
    s_atlas <- as.list(mi_atlas[ input$table_rows_selected, ])
    # Transform NA in Unknown
    s_atlas[is.na(s_atlas)] <- "Unknown" # Otherwise no easy decoding
    # Decode data by groups of column (binary/ternary)
    for( foo in names(s_atlas)){
      value <- as.character( s_atlas[[foo]] )
      # Convert the ternary
      if( foo %in% paste0(c("Outcome_for_P"), 1:3) ){
        s_atlas[[foo]] <- unname(decoding[["ternary"]][ value ])
      # Convert the binary
      } else if( foo %in% c(
        "Specificity",
        "Cost_to_P1", "Cost_to_P2", "Cost_to_P3",
        "Contact_dependent", "Time_dependent", "Space_dependent",
        "Cytoplasm", "Membrane", "Extracellular", "Aquatic", "Biofilm",
        "Food_product", "Multicellular_host", "Soil", "Synthetic", "Ubiquitous",
        "Small_molecules", "Nucleic_acids", "Peptides", "Secondary_metabolites"
      )){
        s_atlas[[foo]] <- unname(decoding[["binary"]][ value ])
      }
    }
    s_atlas
  })
  output$int_no <- renderText({
    paste0("#", input$table_rows_selected)
  })
  output$int_name <- renderText({
    preview_atlas()[ input$table_rows_selected, "Interaction_name"]
  })
  output$int_tax <- renderText({
    paste0(questions[["Taxonomic_resolution"]]," ",
          selected_atlas()[["Taxonomic_resolution"]],". ")
  })
  output$int_specificity <- renderText({
    paste0(questions[["Specificity"]]," ",
          selected_atlas()[["Specificity"]],".")
  })
  output$participant_table<-renderTable({
    # This function should not be ran before a row is selected.
    req(input$table_rows_selected)
    # Assemble the table
    ptable<-matrix(
      data = unlist(selected_atlas()[c(
        "Participant_1", "Domain_1","Cost_to_P1", "Outcome_for_P1",
        "Participant_2", "Domain_2","Cost_to_P2", "Outcome_for_P2",
        "Participant_3", "Domain_3","Cost_to_P3", "Outcome_for_P3")
        ]),
      nrow = 4, ncol = 3, byrow = F)
      # Add the questions as row.names
    rownames(ptable) <- unlist(
      unname(questions[c("Participant", "Domain","Cost", "Outcome")])
      )
    # Drop the third participant column if its name is Unknown
    if(selected_atlas()[["Participant_3"]] == "Unknown"){
      ptable <- ptable[, -3]
    }
    ptable
  }, rownames = T, colnames = F, na = "", hover = T, spacing = "xs")
  output$dependencies_table <- renderTable({
    # This function should not be ran before a row is selected.
    req(input$table_rows_selected)
    # Assemble the table
    ptable<-matrix(
      data = unlist(selected_atlas()[c(
        "Contact_dependent", "Time_dependent", "Space_dependent")]),
      nrow = 3, ncol = 1, byrow = F)
    # Add the questions as row.names
    rownames(ptable) <- unlist(
      unname(questions[c("Participant", "Domain","Cost", "Outcome")])
    )
  }, rownames = T, colnames = T, na = "", hover = T, spacing = "xs")
}

# Run the application 
shinyApp(ui = ui, server = server)

