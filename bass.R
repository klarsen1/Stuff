bass_diffusion <- function(innovation, imitation, tam, years=20){
  units <- 0 
  f <- rep(6000, years+1)
  for (i in 2:length(f)){
    f[i] = f[i-1] + (innovation + imitation*f[i-1]/tam) * (tam-f[i-1])
  }
  return(f)
}

getLS <- function(b){
  x <- round(bass_diffusion(b[1], b[2], tam, length(y)-1))
  return(sum((x-y)^2))
}

res <- optim(par=c(0., 0), 
             lower=c(0, 0), 
             upper=c(10, 10), 
             fn=getLS, 
             method="L-BFGS-B")

res$par
res$value

t <- 15
data.frame(year=as.numeric(2011 + seq(1, t)),
           actual=c(y, rep(NA, t-length(y))), 
           bass=bass_diffusion(res$par[1], res$par[2], tam, t-1), stringsAsFactors = FALSE) %>%
  ggplot() + geom_line(aes(x=year, y=actual), size=1) + 
  geom_line(aes(x=year, y=bass), size=1, linetype=2) +
  scale_y_continuous(labels = scales::comma) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
  scale_x_continuous(breaks=pretty_breaks(10))
