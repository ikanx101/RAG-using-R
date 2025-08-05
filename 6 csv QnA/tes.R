library(ggplot2)
library(dplyr)

df %>%
  group_by(negara) %>%
  summarise(lose_rate = mean(status == "lose")) %>%
  arrange(desc(lose_rate)) %>%
  ggplot(aes(x = reorder(negara, lose_rate), y = lose_rate, fill = lose_rate)) +
  geom_col() +
  scale_fill_gradient(low = "#deebf7", high = "#3182bd") +
  coord_flip() +
  labs(x = "Negara", y = "Lose Rate", title = "Tingkat Kekalahan berdasarkan Negara") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        panel.grid.major.y = element_blank())
