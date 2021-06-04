library(shiny)
library(bslib)
library(DT)
library(shinyFeedback)

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
    "Outcome" = "What is the outcome?",
    "Contact_dependent" = "Contact?",
    "Time_dependent" = "Time?",
    "Space_dependent" = "Space?",
    "Cytoplasm" = "Cytoplasm?",
    "Membrane" = "Membrane?",
    "Extracellular" = "Extracellular?",
    "Aquatic" = "Aquatic?",
    "Biofilm" = "Biofilm?",
    "Food_product" = "Food product?",
    "Multicellular_host" = "Multicellular host?",
    "Soil" = "Soil?", "Synthetic" = "Synthetic?",
    "Ubiquitous" = "Ubiquitous?",
    "Small_molecules" = "Small molecules?", "Nucleic_acids" = "Nucleic acids?",
    "Peptides" = "Peptides?", "Secondary_metabolites" = "Secondary metabolites?"
  )
}

rev.list <- function(lst){
  # Reverse names and objects
  setNames(object = names(lst), nm = lst)
}

if(!exists("tax")){
  tax <- list(
    "domain" = c("Archaea", "Bacteria", "Eukarya", "Viruses"),
    "resolution" = c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")
  )
}

# Define UI
ui <- navbarPage(
  lang = "en", 
  title = "mi-atlas",
  theme = bs_theme( # Based on m.css dark theme
    bg = "#22272e",
    fg = "#ffffff",
    primary = "#5b9dd9",#"#a5c9ea",
    base_font = font_google("Source Sans Pro"),
    code_font = font_google("Source Code Pro")
  ),
  position = "fixed-top",
  footer = list(
    column(hr(),
           p("mi-atlas.",
             a(href="https://cpauvert.github.io/mi-atlas",
               target = "_blank", rel = "noreferrer noopener", icon("globe"),
               "Website"), " / ",
             a(href="https://github.com/cpauvert/mi-atlas/blob/main/CONTRIBUTING.md",
               target = "_blank", rel = "noreferrer noopener", icon("github"),
               "Github")),
           align = "center", width = 12)
  ),
  id = "navbar",
  tabPanel("Browse the catalog", value = "catalog",
           column(width = 12, align = "center",
                  tags$style(type="text/css", "body {padding-top: 70px;}"),
                  h1("An interactive and evolving microbial interactions catalog")),
           column(width = 8, offset = 2,
                  fluidRow(
                    column(width = 6,
                           h2("About mi-atlas", align = "center"),
                           p("Here is the list of interactions occuring between microorganisms that are documented",
                             "in the versioned catalog (see",
                             a(href="https://cpauvert.github.io/mi-atlas",
                               target = "_blank", rel = "noreferrer noopener", "website", .noWS = "after"),
                             ").", "This classification is based on a framework",
                             "suggested by", a(href="https://doi.org/10.1093/femsle/fnz125",
                                               target = "_blank", rel = "noreferrer noopener",
                                               # open in new tab w/ protection
                                               "Pacheco and Segrè (2019)."), align = "left")),
                    column(width = 6,
                           h2("How to explore", align = "center"),
                           tags$ol(
                             tags$li("Browse the following",
                                     a(href="#list", "list"),"of microbial interactions"),
                             tags$li("Select an interaction in the table (e.g. #7)."),
                             tags$li("View the detailed catalog entry using the top bar or the bottom button.")
                           ),
                           helpText("Details on the column names can be found",
                                    a(href="https://github.com/cpauvert/mi-atlas/blob/main/README.md#attributes-of-microbial-interactions",
                                      target = "_blank", rel = "noreferrer noopener",
                                      # open in new tab w/ protection
                                      "here.")),
                           verbatimTextOutput("checkRows")
                    )),
                  fluidRow(
                    h2("List of microbial interactions", align = "center", id="list"),
                    DT::dataTableOutput("table")
                  ),
                  br(),
                  column(width = 12, align = "center",
                         actionButton(inputId = "viewDetail",
                                      "View detailed entry of the interaction",
                                      width = "250px")
                  )
           )),
  tabPanel("View detailed entry", value = "detail",
           fluidRow(
             column(width = 8, offset = 2,
                    h2("Details on the interaction", textOutput("int_no", inline = T),
                       id="interaction-details", align = "center"),
                    h3("Interaction name:", textOutput("int_name", inline = T), align = "center"),
                    h4("Interaction participants"),
                    column(width = 10, offset = 1, tableOutput("participant_table")),
                    h4("Taxonomy and specificity"),
                    tags$ul(
                      tags$li(textOutput("int_tax")),
                      tags$li(textOutput("int_specificity"))
                    ),
                    h4("Interaction features"),
                    fluidRow(
                      column(width = 5, offset = 1, h5("Dependencies"), tableOutput("dependencies_table")),
                      column(width = 5, offset = 1, h5("Site"), tableOutput("site_table"))
                    ),
                    fluidRow(
                      column(width = 5, offset = 1, h5("Habitat"), tableOutput("habitat_table")),
                      column(width = 5, offset = 1, h5("Compounds"), tableOutput("compounds_table"))
                    ),
                    h4("References"),
                    tags$ul(uiOutput("references"))
             )
           ),
           br(),
           fluidRow(
             column(width = 4, offset = 2, align = "center",
                    actionButton(inputId = "viewCatalog",
                                 "Explore another entry in the catalog of interactions",
                                 width = "250px")),
             column(width = 4, align = "center",
                    actionButton(inputId = "viewNewEntry",
                                 "Suggest a new interaction for the catalog",
                                 width = "250px"))
           )
  ),
  tabPanel("Add an interaction", value = "new-mi-entry",
           useShinyFeedback(),
           column(width = 8, offset = 2,
                  h2("Contribute to the catalog with a new microbial interaction", align = "center"),
                  fluidRow(
                    column(width = 6,
                           p("In short, to contribute you need to:",
                             tags$ol(
                               tags$li("Fill the", a(href="#form","form"),"below"),
                               tags$li("Press the 'Generate the new entry'", a(href="#generate", "button")),
                               tags$li("Copy the encoded entry which is a new line of the tab-separated catalog"),
                               tags$li(a(href="https://github.com/cpauvert/mi-atlas/blob/main/mi-atlas.tsv", "Edit"),
                                       "the tab-separated catalog (",
                                       a(href="https://docs.github.com/en/github/managing-files-in-a-repository/managing-files-on-github/editing-files-in-another-users-repository",
                                         target = "_blank", rel = "noreferrer noopener", "how-to", .noWS = "before"), "if need be)"),
                               tags$li("Submit a pull request with your new entry.")
                             )
                           )),
                    column(width = 6,
                           p("Thank you for your willingness to contribute!",
                             "Feel free to have a look to the",
                             a(href="https://github.com/cpauvert/mi-atlas/blob/main/CONTRIBUTING.md",
                               target = "_blank", rel = "noreferrer noopener","contribution guidelines"),
                             "of the repository."),
                           helpText("The form accepts either free mandatory text or pre-computed answers (Yes/No/Unknown).",
                                    "Questions were designed to encode the new interaction into the",
                                    a(href="https://cpauvert.github.io/mi-atlas/framework.html",
                                      target = "_blank", rel = "noreferrer noopener", "framework."))
                    )
                  ),
                  h4("Interaction participants", id = "form"),
                  fluidRow(
                    column(width = 3,
                           radioButtons(inputId = "n_p_no", label = "How many participants in the new interaction?",
                                        choices = c("2" = 2, "3" = 3),
                                        inline = T)),
                    column(width = 3,
                           textInput(inputId = "n_p1", label = "Participant 1?")),
                    column(width = 3,
                           textInput(inputId = "n_p2", label = "Participant 2?")),
                    column(width = 3,
                           textInput(inputId = "n_p3", label = "No participant 3", value = "Unknown"))
                  ),
                  fluidRow(
                    column(width = 3, p(questions["Domain"],
                                        helpText("Multiple domains allowed for consortium"))),
                    column(width = 3,
                           selectInput(inputId = "n_dom_p1", label = "Participant 1?",
                                       choices = tax[["domain"]], multiple = T)),
                    column(width = 3,
                           selectInput(inputId = "n_dom_p2", label = "Participant 2?",
                                       choices = tax[["domain"]], multiple = T)),
                    column(width = 3,
                           selectInput(inputId = "n_dom_p3", label = "No participant 3",
                                       choices = c(tax[["domain"]], "Unknown"), multiple = T, selected = "Unknown"))
                  ),
                  fluidRow(
                    column(width = 3, p(questions["Cost"])),
                    column(width = 3,
                           radioButtons(inputId = "n_cost_p1", label = "Participant 1?", inline = T,
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown")),
                    column(width = 3,
                           radioButtons(inputId = "n_cost_p2", label = "Participant 2?", inline = T,
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown")),
                    column(width = 3,
                           radioButtons(inputId = "n_cost_p3", label = "No participant 3", inline = T,
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown"))
                  ),
                  fluidRow(
                    column(width = 3, p(questions["Outcome"])),
                    column(width = 3,
                           selectInput(inputId = "n_outcome_p1", label = "Participant 1?",
                                       choices = rev.list(decoding[["ternary"]]), selected = "Unknown")),
                    column(width = 3,
                           selectInput(inputId = "n_outcome_p2", label = "Participant 2?",
                                       choices = rev.list(decoding[["ternary"]]), selected = "Unknown")),
                    column(width = 3,
                           selectInput(inputId = "n_outcome_p3", label = "No participant 3",
                                       choices = rev.list(decoding[["ternary"]]), selected = "Unknown"))
                  ),
                  h4("Taxonomy and specificity"),
                  fluidRow(
                    column(width = 3, p(questions["Taxonomic_resolution"])),
                    column(width = 3,
                           selectInput(inputId = "n_taxres_p1", label = "Participant 1?",
                                       choices = tax[["resolution"]], selected = "Species")),
                    column(width = 3,
                           selectInput(inputId = "n_taxres_p2", label = "Participant 2?",
                                       choices = tax[["resolution"]], selected = "Species")),
                    column(width = 3,
                           selectInput(inputId = "n_taxres_p3", label = "No participant 3",
                                       choices = c(tax[["resolution"]], "Unknown"), selected = "Unknown"))
                  ),
                  fluidRow(
                    column(width = 3, p(questions["Specificity"])),
                    column(width = 4,
                           radioButtons(inputId = "n_specificity", label = NULL, inline = T,
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown")
                    )
                  ),
                  h4("Interaction features"),
                  h5("Dependencies"),
                  fluidRow(
                    column(width = 3, p("Are there reported dependencies on the interaction?")),
                    column(width = 3,
                           radioButtons(inputId = "n_site_contact", label = questions[["Contact_dependent"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T)),
                    column(width = 3,
                           radioButtons(inputId = "n_site_time", label = questions[["Time_dependent"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T)),
                    column(width = 3,
                           radioButtons(inputId = "n_site_space", label = questions[["Space_dependent"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T))
                  ),
                  h5("Site"),
                  fluidRow(
                    column(width = 3, p("What is the site of the mechanism of interaction at the cellular level?")),
                    column(width = 3,
                           radioButtons(inputId = "n_dep_cytoplasm", label = questions[["Cytoplasm"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T)),
                    column(width = 3,
                           radioButtons(inputId = "n_dep_membrane", label = questions[["Membrane"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T)),
                    column(width = 3,
                           radioButtons(inputId = "n_dep_extracellular", label = questions[["Extracellular"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T))
                  ),
                  h5("Habitat"),
                  fluidRow(
                    column(width = 3, p("What is the biome where the interaction takes place?")),
                    column(width = 2,
                           radioButtons(inputId = "n_hab_aquatic", label = questions[["Aquatic"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T)),
                    column(width = 2,
                           radioButtons(inputId = "n_hab_biofilm", label = questions[["Biofilm"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T)),
                    column(width = 2,
                           radioButtons(inputId = "n_hab_food", label = questions[["Food_product"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T)),
                    column(width = 3,
                           radioButtons(inputId = "n_hab_host", label = questions[["Multicellular_host"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T))
                  ),
                  fluidRow(
                    column(width = 2, offset = 4,
                           radioButtons(inputId = "n_hab_soil", label = questions[["Soil"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T)),
                    column(width = 2,
                           radioButtons(inputId = "n_hab_synthetic", label = questions[["Synthetic"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T)),
                    column(width = 2,
                           radioButtons(inputId = "n_hab_ubiquitous", label = questions[["Ubiquitous"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T))
                  ),
                  h5("Compounds"),
                  fluidRow(
                    column(width = 3, p("What type of compounds are involved?")),
                    column(width = 3,
                           radioButtons(inputId = "n_comp_mol", label = questions[["Small_molecules"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T)),
                    column(width = 3,
                           radioButtons(inputId = "n_comp_nucleic", label = questions[["Nucleic_acids"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T)),
                    column(width = 3,
                           radioButtons(inputId = "n_comp_peptides", label = questions[["Peptides"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T))
                  ),
                  fluidRow(
                    column(width = 3, offset = 6,
                           radioButtons(inputId = "n_comp_metabolites", label = questions[["Secondary_metabolites"]],
                                        choices = rev.list(decoding[["binary"]]), selected = "Unknown", inline = T))
                  ),
                  h4("References"),
                  fluidRow(
                    column(width = 3, p("What peer-reviewed articles document the interaction?")),
                    column(width = 9,
                           textInput("n_reference_1", label = "DOI of the article", placeholder = "e.g. 10.1010/pnh.1010"),
                           actionLink("more_reference", "Additional reference", icon = icon("plus-square"))
                    )
                  ),
                  h4("Build the new entry using the framework", id="generate"),
                  fluidRow(
                    column(width = 3, p("The new entry will be generated with the following name")),
                    column(width = 4,
                           textInput(inputId = "n_int_name", label = "Interaction name (pre-filled)")),
                    column(width = 4,
                           actionButton("n_render", "Generate the new entry", style = 'margin-top:31px'))
                  ),
                  verbatimTextOutput("rendered_entry")
           )
  )
)

# Define server logic
server <- function(input, output, session) {
  preview_atlas <- reactive({
    mi_atlas[ , c("Interaction_name",
                  "Participant_1",
                  "Participant_2",
                  "Participant_3")]
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
    dtable<-matrix(
      data = unlist(selected_atlas()[c(
        "Contact_dependent", "Time_dependent", "Space_dependent")]),
      nrow = 3, ncol = 1, byrow = F)
    # Add the questions as row.names
    rownames(dtable) <- unlist(
      unname(questions[c("Contact_dependent", "Time_dependent", "Space_dependent")])
    )
    colnames(dtable) <- "Dependencies"
    dtable
  }, rownames = T, colnames = F, na = "", hover = T, spacing = "xs")
  output$site_table <- renderTable({
    # This function should not be ran before a row is selected.
    req(input$table_rows_selected)
    # Assemble the table
    stable<-matrix(
      data = unlist(selected_atlas()[c(
        "Cytoplasm", "Membrane", "Extracellular")]),
      nrow = 3, ncol = 1, byrow = F)
    # Add the questions as row.names
    rownames(stable) <- unlist(
      unname(questions[c("Cytoplasm", "Membrane", "Extracellular")])
    )
    colnames(stable) <- "Site"
    stable
  }, rownames = T, colnames = F, na = "", hover = T, spacing = "xs")
  output$habitat_table <- renderTable({
    # This function should not be ran before a row is selected.
    req(input$table_rows_selected)
    # Assemble the table
    htable<-matrix(
      data = unlist(selected_atlas()[c(
        "Aquatic", "Biofilm", "Food_product",
        "Multicellular_host", "Soil", "Synthetic", "Ubiquitous")]),
      nrow = 7, ncol = 1, byrow = F)
    # Add the questions as row.names
    rownames(htable) <- unlist(
      unname(questions[c("Aquatic", "Biofilm", "Food_product",
                         "Multicellular_host", "Soil", "Synthetic", "Ubiquitous")])
    )
    colnames(htable) <- "Habitat"
    htable
  }, rownames = T, colnames = F, na = "", hover = T, spacing = "xs")
  output$compounds_table <- renderTable({
    # This function should not be ran before a row is selected.
    req(input$table_rows_selected)
    # Assemble the table
    ctable<-matrix(
      data = unlist(selected_atlas()[c(
        "Small_molecules", "Nucleic_acids", "Peptides", "Secondary_metabolites")]),
      nrow = 4, ncol = 1, byrow = F)
    # Add the questions as row.names
    rownames(ctable) <- unlist(
      unname(questions[c("Small_molecules", "Nucleic_acids", "Peptides", "Secondary_metabolites")])
    )
    colnames(ctable) <- "Site"
    ctable
  }, rownames = T, colnames = F, na = "", hover = T, spacing = "xs")
  output$references <- renderUI({
    # This function should not be ran before a row is selected.
    req(input$table_rows_selected)
    # Extract the references separated by ";"
    refs <- unlist(strsplit(
      selected_atlas()[["References"]], ";"
    ))
    # Format the links
    lapply(refs, function(reference){
      tags$li(
        tags$a(
          href=paste0("https://doi.org/", reference),
          target = "_blank", rel = "noreferrer noopener",
          paste("doi:", reference)
        )
      )
    })
  })
  # Navigation
  #
  observeEvent(input$viewDetail, {
    updateNavbarPage(session = session, inputId = "navbar", selected = "detail")
  })
  observeEvent(input$viewCatalog, {
    updateNavbarPage(session = session, inputId = "navbar", selected = "catalog")
  })
  observeEvent(input$viewNewEntry, {
    updateNavbarPage(session = session, inputId = "navbar", selected = "new-mi-entry")
  })
  #
  # New entry
  #
  output$min_int_no <- renderText({ nrow(mi_atlas)+1 })
  # Better navigation buttons with updated informations
  observe({
    req(input$table_rows_selected)
    updateActionButton(session = session, inputId = "viewDetail",
                       label = paste0("View detailed entry of the interaction #",
                                      input$table_rows_selected))
    updateTextInput(session, "n_int_name",
                    value = paste(input$n_p1, input$n_p2, sep = " - "))
  })
  # Update form depending on change in participant number
  observeEvent(input$n_p_no, {
    if(input$n_p_no == 2){
      updateTextInput(session, "n_p3", value = "Unknown", label = "No participant 3")
      updateSelectInput(session, "n_dom_p3", selected = "Unknown", label = "No participant 3")
      updateRadioButtons(session, "n_cost_p3", selected = "Unknown", label = "No participant 3")
      updateSelectInput(session, "n_outcome_p3", selected = "Unknown", label = "No participant 3")
      updateSelectInput(session, "n_taxres_p3", selected = "Unknown", label = "No participant 3")
    } else {
      showNotification("Three participants selected for new entry", type = "message")
      updateTextInput(session, "n_p3", value = "", label = "Participant 3?")
      updateSelectInput(session, "n_dom_p3", selected = "", label = "Participant 3?")
      updateRadioButtons(session, "n_cost_p3", selected = "Unknown", label = "Participant 3?")
      updateSelectInput(session, "n_outcome_p3", selected = "Unknown", label = "Participant 3?")
      updateSelectInput(session, "n_taxres_p3", selected = "Species", label = "Participant 3?")
    }
  }, ignoreInit = T)
  # Add more reference field if needed
  #
  observeEvent(input$more_reference, {
    insertUI("#n_reference_1", where = "afterEnd",
             ui = textInput(paste0("n_reference_", input$more_reference+1), "DOI of the article")
    )
  })
  references <- reactive({
    # At least one is required
    req(input$n_reference_1)
    # Fetch the references fields
    #  based on https://stackoverflow.com/a/40045292
    refs <- rev(sapply(grep("n_reference_", names(input), value = T), function(x) input[[x]]))
    # Remove empty fields in case
    refs <- refs[ refs != "" ]
    # Paste together references fields
    paste(refs, collapse = ";")
  })
  tax_resolution <- reactive({
    req(input$n_taxres_p1, input$n_taxres_p2, input$n_taxres_p3)
    tax <- c(input$n_taxres_p1, input$n_taxres_p2, input$n_taxres_p3)
    # Lower case the 2nd and 3rd
    tax[2:3] <- sapply(tax[2:3], tolower)
    # Remove the 3rd field if no 3rd participant
    if(input$n_p_no == 2){
      tax <- tax[1:2]
    }
    # Paste together the taxonomic resolution
    paste(tax, collapse = "-")
  })
  # List the necessary inputs following the columns of the atlas
  atlas_fields <- reactive(
    c(
      input$n_int_name,
      input$n_p1,
      input$n_p2,
      input$n_p3,
      tax_resolution(),
      input$n_dom_p1,
      input$n_dom_p2,
      input$n_dom_p3,
      input$n_specificity,
      input$n_cost_p1,
      input$n_cost_p2,
      input$n_cost_p3,
      input$n_outcome_p1,
      input$n_outcome_p2,
      input$n_outcome_p3,
      input$n_site_contact,
      input$n_site_time,
      input$n_site_space,
      input$n_dep_cytoplasm,
      input$n_dep_membrane,
      input$n_dep_extracellular,
      input$n_hab_aquatic,
      input$n_hab_biofilm,
      input$n_hab_food,
      input$n_hab_host,
      input$n_hab_soil,
      input$n_hab_synthetic,
      input$n_hab_ubiquitous,
      input$n_comp_mol,
      input$n_comp_nucleic,
      input$n_comp_peptides,
      input$n_comp_metabolites,
      references())
  )
  #
  # Format the new entry
  #
  show_entry <- eventReactive(input$n_render,{
    req(atlas_fields)
    # Fetch the inputs
    fields <- setNames(atlas_fields(), colnames(mi_atlas))
    # Replace Unknown by NA values
    fields[ fields == "Unknown" ] <- NA
    # Force integer values where necesary
    integer_fields <- c("Specificity", "Cost_to_P1", "Cost_to_P2",
                        "Cost_to_P3", "Outcome_for_P1", "Outcome_for_P2", 
                        "Outcome_for_P3", "Contact_dependent", "Time_dependent",
                        "Space_dependent", "Cytoplasm", "Membrane", "Extracellular",
                        "Aquatic", "Biofilm", "Food_product", "Multicellular_host",
                        "Soil", "Synthetic", "Ubiquitous", "Small_molecules",
                        "Nucleic_acids", "Peptides", "Secondary_metabolites")
    fields[integer_fields] <- lapply(fields[integer_fields], strtoi)
    # Convert to data.frame
    foo <- data.frame(as.list(fields))
    # Add the proper row number for a new entry
    rownames(foo) <- nrow(mi_atlas)+1
    foo
  })
  output$rendered_entry <- renderPrint(
    write.table(show_entry(), file = "", quote = T, col.names = F, sep = "\t")
  )
  # Form raw validation
  #
  observeEvent(input$n_render,{
    lapply(c("n_p1","n_p2", "n_dom_p1", "n_dom_p2", "n_reference_1"), function(foo){
      feedbackDanger(foo, input[[foo]] == "",
                     "Mandatory fields")
    })
    if(input$n_p_no == 3){
      lapply(c("n_p3", "n_dom_p3"), function(foo){
        feedbackDanger(foo, input[[foo]] == "",
                       "Mandatory fields")
      })
    }
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

