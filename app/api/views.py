from rest_framework import views
from rest_framework import response

class HelloAPIView(views.APIView):

    def get(self, request, *args, **kwargs):
        return response.Response(data={'msg': 'hi'}, status=200)
