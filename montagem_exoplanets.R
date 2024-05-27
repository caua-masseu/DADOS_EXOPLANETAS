

library(tidyverse)

url <- "https://nssdc.gsfc.nasa.gov/planetary/factsheet/"
read_html(url) -> page
html_table(page, header = T)[[1]][-21,] -> table
colnames(table) <- c("Variables", "Mercury", "Venus", "Earth",  "Moon" , "Mars",  "Jupiter", "Saturn", "Uranus" , "Neptune", "Pluto")

table <- table %>% pivot_longer(cols = 2:11, names_to = "PLANETS", values_to = "Valor") %>% pivot_wider(names_from = Variables, values_from = Valor)
table$`Mass (1024kg)` <- as.numeric(gsub(pattern = ",", replacement = ".", table$`Mass (1024kg)`))/5.970        #put in EARTH MASS which measure
table$`Diameter (km)` <- as.numeric(gsub(pattern = ",", replacement = ".", table$`Diameter (km)`))/(12.756)     #put in EARTH RADIUS
table$`Density (kg/m3)` <- as.numeric(gsub(pattern = ",", replacement = ".", table$`Density (kg/m3)`))/1000     #put in g/cm^3
table$`Orbital Period (days)` <- as.numeric(gsub(pattern = ",", replacement = ".", x =  gsub(pattern = "\\*", replacement = "", table$`Orbital Period (days)`)))
table$`Orbital Velocity (km/s)` <- as.numeric(gsub(pattern = ",", replacement = ".", x = gsub(pattern = "\\*", replacement = "", table$`Orbital Velocity (km/s)`))) * 1000 #put in (m/s)
table$`Orbital Inclination (degrees)` <- as.numeric(gsub(pattern = ",", replacement = ".", table$`Orbital Inclination (degrees)`))
table$`Orbital Eccentricity` <- as.numeric(gsub(pattern = ",", replacement = ".", table$`Orbital Eccentricity` ))
table$`Obliquity to Orbit (degrees)` <- as.numeric(gsub(pattern = ",", replacement = ".", table$`Obliquity to Orbit (degrees)`))
table <- table[, c(1:4, 12:16)] %>% filter(PLANETS != "Moon") #Escolhendo continuas
table$pl_eqt <- c(449, 328, 279, 226, 122, 90, 64, 51, 44)
colnames(table) <- c("pl_name",  "pl_masse", "pl_rade", "pl_dens", "pl_orbper", "pl_rvamp", "pl_orbincl", "pl_orbeccen","pl_trueobliq", "pl_eqt")

PS_2024 <-read.csv("https://raw.githubusercontent.com/caua-masseu/DADOS_EXOPLANETAS/main/PS_2024.05.23_16.45.53.csv")

PS_2024 %>% group_by(pl_name) %>% filter(pl_pubdate == max(pl_pubdate)) -> data
data <- data[,-c(9:11)]
data %>% distinct() -> data

df <- rbind(data, table)
df <- df[, -c(3,7, 9:12)] %>% drop_na()
df <- df[-c(30, 139),]
df <- column_to_rownames(df, var = "pl_name")
colnames(df) <- c("orbper", "rade", "mass", "dens", "eqt")
df$orbper <- log(df$orbper)
df$rade <- log(df$rade)
df$mass <- log(df$mass)
df$dens <- log(df$dens)
df$eqt <- df$eqt/1000
