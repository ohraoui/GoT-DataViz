#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shinydashboard)
library(shiny)
library(readr)
library(ggplot2)
library(knitr)
library(dplyr)
library(sf)
library(rCharts)
library(plotly)

# Define UI for application that draws a histogram
ui <- shinyUI(navbarPage("Analyse GOT",
                         tabPanel("Personnages & Lieux",
                                  fluidPage(
                                      fluidRow(
                                          column(width = 12,
                                                 h4(em("Nous avons tout d'abord essayé d'avoir un graphe interactif qui permet de visualiser les lieux en fonction de leur nombre d'apparitions dans la série. Nous avons également repris la carte qui permet de voir le nombre d'apparaitions dans chaque lieu de la série en utilisant la taille des points, ainsi que le graphe reprenant le nombre d'apparitions de chaque personnage par épisode.")),
                                                 sidebarPanel( 
                                                     tags$style(type="text/css", "select { max-width: 199px; }"),
                                                     h4("Filtrer par saison :"),
                                                     helpText("Sélectionner une saison pour voir les changements dans les graphes"),
                                                     ##
                                                     checkboxGroupInput(inputId ="Season", 
                                                                        label = h5(em("Saison")), 
                                                                        choices = list("1","2","3","4","5","6","7","8"),
                                                                        selected = c("1","2","3","4","5","6","7","8")),
                                                     position = "left"
                                                     ##
                                                 ),
                                                 mainPanel(
                                                     h4("\n"),
                                                     h4("\n"),
                                                     tags$p(),
                                                     h4(em("Apparition des lieux par saison")),
                                                     showOutput("plot1", lib="nvd3"),
                                                     hr())
                                          )),
                                      fluidRow(
                                          column(width = 12,
                                                 h4(em("")),
                                                 # Define the sidebar with one input
                                                 sidebarPanel(
                                                     selectInput("Names", "Noms :", 
                                                                 choices=c("Jon Snow", "Tyrion Lannister","Daenerys Targaryen","Sansa Stark","Cersei Lannister","Arya Stark")),
                                                     position = "left"),
                                                 mainPanel(
                                                     plotOutput("plot3", width = 700, height = 700))
                                          )),
                                      fluidRow(
                                          column(width = 12,
                                                 # Define the sidebar with one input
                                                 sidebarPanel(
                                                     selectInput("Names_again", "Noms :", 
                                                                 choices=c("Jon Snow", "Tyrion Lannister","Daenerys Targaryen","Sansa Stark","Cersei Lannister","Arya Stark")),
                                                     position = "left"),
                                                 mainPanel(
                                                     plotOutput("plot2"))
                                          ))
                                  )
                         ),
                         tabPanel("Temps total à l'écran",
                                  fluidPage(
                                      fluidRow(
                                          column(12, wellPanel(tags$p(),
                                                               h4(em("Dans un premier temps, nous avons essayé de reprendre le graphe avec les personnages principaux que nous avons choisis. Ce graphe donne la durée pendant laquelle chaque personnage est apparu dans la série suivant les saisons. A l'aide ggplotly, le graphe donne la valeur du screenTime/60 (i.e. nombre de minutes) pendants lequel chacun des personnages est apparu durant la série."))),
                                                 mainPanel(
                                                     plotlyOutput("plot6", width = 1000, height = 500)
                                                 ))
                                      ),
                                      fluidRow(
                                          column(12, wellPanel(tags$p(),
                                                               h4(em("Par la suite, nous utilisons un SliderInput afin de visualiser le temps d'apparation de chaque personage pendant chaque saison. Ce graphe interactif permet de choisir une saison, les couleurs et valeurs étant différentes pour chacune.")),
                                                               h4(em("\n")),
                                                               sliderInput("n", "Saison :", min = 1, max = 8, value = 200,
                                                                           step = 1),
                                                               mainPanel(
                                                                   plotOutput("plot4", width = 800, height = 500)
                                                               )))),
                                      fluidRow(
                                          column(12, wellPanel(tags$p(),
                                                               h4(em("Enfin, nous utilisons la couleur et la taille des points pour encoder des informations sur les saisons et le nombre de morts et finaliser le graphique qui pourrait ressembler à cette version en paramétrant les échelles et en rajoutant quelques labels. Nous avons aussi utlisé ggplotly pour avoir un graphe qui donne les informations sur chaque point une fois le curseur dessus.")),
                                                               mainPanel(
                                                                   plotlyOutput("plot5", width = 800, height = 800))
                                          ))
                                      )
                                  )
                         )))

# Define server logic required to draw a histogram
server <- function(input, output) {
    colforest="#c0d7c2"
    colriver="#7ec9dc"
    colriver="#d7eef4"
    colland="ivory"
    borderland = "ivory3"
    characters = read_csv("data/characters.csv")
    episodes = read_csv("data/episodes.csv")
    scenes = read_csv("data/scenes.csv")
    appearances = read_csv("data/appearances.csv")
    screenTimePerSeasons = appearances %>% left_join(scenes) %>% left_join(episodes) %>% group_by(name,seasonNum) %>% summarise(screenTime=sum(duration)) %>% arrange(desc(screenTime)) 
    screenTimeTotal = screenTimePerSeasons %>% group_by(name) %>% summarise(screenTimeTotal=sum(screenTime))
    mainCharacters = screenTimeTotal %>% filter(screenTimeTotal>60*60) %>% arrange(screenTimeTotal) %>% mutate(nameF=factor(name,levels = name))
    # Fill in the spot we created for a plot
    output$plot2 <- renderPlot({
        jstime  <- appearances %>% filter(name==input$Names_again) %>% left_join(scenes) %>% group_by(episodeId) %>% summarise(time=sum(duration))
        ggplot(jstime) + geom_line(aes(x=episodeId,y=time),stat='identity')+ theme_bw()+ xlab("Episode")+ylab("Temps")+ ggtitle(input$names)
    })
    
    colforest="#c0d7c2"
    colriver="#7ec9dc"
    colriver="#d7eef4"
    colland="ivory"
    borderland = "ivory3"
    colors = c("YlOrRd", "YlGnBu","YlGn", "BuPu","RdPu","Accent", "Dark2","Paired")
    # Fill in the spot we created for a plot
    output$plot3 <- renderPlot({
        scenes_locations=st_read("data/GoTRelease/ScenesLocations.shp",crs=4326)
        locations=st_read("./data/GoTRelease/Locations.shp",crs=4326)
        lakes=st_read("./data/GoTRelease/Lakes.shp",crs=4326)
        conts=st_read("./data/GoTRelease/Continents.shp",crs=4326)
        land=st_read("./data/GoTRelease/Land.shp",crs=4326)
        wall=st_read("./data/GoTRelease/Wall.shp",crs=4326)
        islands=st_read("./data/GoTRelease/Islands.shp",crs=4326)
        kingdoms=st_read("./data/GoTRelease/Political.shp",crs=4326)
        landscapes=st_read("./data/GoTRelease/Landscape.shp",crs=4326)
        roads=st_read("./data/GoTRelease/Roads.shp",crs=4326)
        rivers=st_read("./data/GoTRelease/Rivers.shp",crs=4326)
        
        loc_time=appearances %>% filter(name==input$Names) %>% left_join(scenes) %>% group_by(location) %>% summarize(duration=sum(duration,na.rm=TRUE)) 
        loc_time_js = scenes_locations %>% left_join(loc_time)
        ggplot()+geom_sf(data=land,fill=colland,col=borderland,size=0.1)+
            geom_sf(data=islands,fill=colland,col="ivory3")+
            geom_sf(data=landscapes %>% filter(type=="forest"),fill=colforest,col=colforest,alpha=0.7)+
            geom_sf(data=rivers,col=colriver)+
            geom_sf(data=lakes,col=colriver,fill=colriver)+
            geom_sf(data=wall,col="black",size=1)+
            geom_sf(data=loc_time_js,aes(size=duration/60),color="#f564e3")+
            geom_sf_text(data= locations %>% filter(size>4,name!='Tolos'),aes(label=name),size=2.8,family="Palatino", fontface="italic",vjust=0.7)+
            theme_minimal()+coord_sf(expand = 0,ndiscr = 0)+
            scale_size_area("Durées (min) :",max_size = 16,breaks=c(30,60,120,240))+
            theme(panel.background = element_rect(fill = colriver,color=NA),legend.position = "bottom") +
            labs(title = "Répartition spatiale des scènes",x="",y="")
    })
    joint = scenes %>% left_join(episodes)
    joint_bis = joint[which(as.factor(joint$location) %in% c("North of the Wall","The Crownlands","The North","The Riverlands","The Wall","Bravos","Meereen")),]
    selectedData1 <- reactive({
        joint_bis[which(as.factor(joint_bis$seasonNum) %in% input$Season),]
    })
    output$plot1 <- renderChart({
        #
        p1 <- nPlot(~ location, group = 'seasonNum', data = selectedData1(), type = 'multiBarChart')
        p1$chart(showControls = F)
        p1$addParams(dom = 'plot1', title="test")
        p1$xAxis(axisLabel = "Lieux")
        p1$chart(color = c('#413657', '#265475', '#353817', '6C2224', '#4F0F0F', '777274'))
        ##
        return(p1)
    })
    output$plot6 <- renderPlotly({data = screenTimePerSeasons %>% left_join(mainCharacters) %>% filter(!is.na(nameF))
    data_2 = data[which(as.factor(data$name) %in% c("Jon Snow", "Tyrion Lannister","Daenerys Targaryen","Sansa Stark","Cersei Lannister","Arya Stark")),]
    ggplotly(ggplot(data_2)+
                 geom_bar(aes(y=nameF,x=screenTime/60,fill=factor(seasonNum,level=8:1)),stat="identity")+
                 scale_fill_brewer("Saison",palette = "Spectral")+theme_bw()+
                 geom_text(data=data_2,aes(y=nameF,x=screenTimeTotal/60+5,label=paste("                ", round(screenTimeTotal/60),'min')),hjust = "left")+
                 scale_x_continuous("Temps d'apparition (min)",breaks = seq(0,750,by=120),limits = c(0,780),expand = c(0,1))+
                 ylab("")+ggtitle("Temps d'apparition cumulé par personnage et saison"))})  
    
    output$plot4 <- renderPlot({
        joint_2 = screenTimePerSeasons %>% left_join(mainCharacters) %>% filter(!is.na(nameF))
        selectedData2 = joint_2[which(as.factor(joint_2$seasonNum) %in% input$n),]
        selectedData3 = selectedData2[which(as.factor(selectedData2$name) %in% c("Jon Snow", "Tyrion Lannister","Daenerys Targaryen","Sansa Stark","Cersei Lannister","Arya Stark")),]
        ggplot(selectedData3)+ geom_bar(aes(y=nameF,x=screenTime/60,fill=factor(seasonNum,level=8:1)),stat="identity")+scale_fill_brewer("Saison",palette = colors[input$n])+theme_bw()+geom_text(data=selectedData3,aes(y=nameF,x=screenTimeTotal/60+5, label = " "),hjust = "left")+scale_x_continuous("Temps d'apparition (min)",breaks = seq(0,750,by=120),limits = c(0,150),expand = c(0,1))+
            ylab("")+ggtitle("Temps d'apparition cumulé par personnage et saison")})
    
    output$plot5 <- renderPlotly({scenes_stats=scenes %>% left_join(episodes) %>%   group_by(episodeTitle,seasonNum) %>% summarize(nb_scenes=n(),duration_max=max(duration),nbdeath=sum(nbdeath))
    labels = scenes_stats %>% filter(duration_max>400|nb_scenes>200)
    ggplotly(ggplot(scenes_stats,aes(x=nb_scenes,y=duration_max,col=factor(seasonNum)))+
                 geom_point(aes(size=nbdeath))+
                 geom_text(data=labels,aes(label=episodeTitle),vjust=-0.6)+
                 scale_x_continuous("Nombre de scènes",limits = c(0,280))+
                 scale_y_continuous("Durée de la scène la plus longue",limits = c(100,800))+
                 scale_color_brewer("Saison",palette ="Spectral")+
                 guides(colour = "legend", size = "legend")+
                 theme_bw())})
}

# Run the application 
shinyApp(ui = ui, server = server)
