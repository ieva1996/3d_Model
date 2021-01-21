
### Required Libraries
# install.packages("devtools")
#devtools::install_github("tylermorganwall/rayshader")
library(rayshader)

### State Data
#install.packages("poliscidata")

library(poliscidata)

### Get Map Data

df<-data.frame(states)
df<- df %>% mutate(state=as.character(state)) %>% dplyr::select(state, urban)

### Clean Text
library(textclean)
df$state<-replace_white(df$state)  
df$state<-strip(df$state)

### Create Map

library(urbnmapr)

# create a tibble with state name abbreviations
state_abbreviations <- tibble(state = c(state.name, "District of Columbia"),abbreviation = c(state.abb, "DC"))

usa_match <- df %>% group_by(state) %>% mutate(xdimension = 1, ydimension = 1) %>% mutate(pop= urban)  #Sum by State and Value


# merge state abbreviations on to bad_drivers based on state
usa_match_merge <- left_join(x = usa_match, y = state_abbreviations, by = "state")
usa_match_merge <-data.frame(usa_match_merge)


library(Hmisc)
usa_match_merge_tree <-usa_match_merge %>% mutate(state=Hmisc::capitalize(state)) %>% dplyr::select(state, pop)


#obtain state map from urbnmapr
states_sf <- get_urbn_map(map = "states", sf = TRUE)  #urban mapper

#Combine Data
spatial_data <- left_join(get_urbn_map(map = "states", sf = TRUE),usa_match_merge_tree,by = c("state_name"="state"))


### Create Map
# Title
title<-c("Total Sales")

map<-ggplot() + geom_sf(spatial_data, mapping = aes(fill = pop), color = "#ffffff", size = 0.25) + 
  geom_sf_text(data = get_urbn_labels(map = "states", sf = TRUE), aes(label = state_abbv), size = 3) + labs(fill = title)

### Create 3D Map
plot_gg(map, width = 5, height = 5, multicore = TRUE, scale = 250,
        zoom = 0.7, theta = 10, phi = 30, windowsize = c(800, 800))
Sys.sleep(0.2)
render_snapshot(clear = TRUE)
