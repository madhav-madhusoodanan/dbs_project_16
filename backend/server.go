package main

import (
	"github.com/gin-gonic/gin"
	"github.com/madhav-madhusoodanan/dbs-assignment/controllers"
)

func main() {
	// gin.SetMode(gin.ReleaseMode)
	server := gin.Default()

	student := server.Group("/read")
	{
		student.POST("/course", controllers.GetStudentCount)
		student.POST("/student", controllers.GetCourses)
	}
	
	edit := server.Group("/edit")
	{
		edit.POST("/add", controllers.AddCourse)
		edit.POST("/substi", controllers.SubstituteCourse)
	}

	/* port, exists := os.LookupEnv("PORT")
	if !exists {
		port = ":8080"
	} else {
		port = ":" + port
	} */

	server.Run(":8080")
}