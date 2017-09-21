.ProcessWebPage <- function(request.str){
  
  response  <- httr::GET(request.str)
  resp.code <- httr::status_code(response)
  
  if (resp.code == "200"){
      return (httr::content(response))
  }
  else{
    stop (paste("Unable to connect to ",
                request.str, " (", resp.code, ")", sep=""))
  }
}