# medicalpromax_backend/apps/users/views.py
"""
Authentication views for MedicalProMax
Register, Login, Refresh Token, Logout, User Profile
"""

from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from rest_framework_simplejwt.tokens import RefreshToken

from .models import User
from .serializers import (
    UserSerializer, UserRegisterSerializer, UserProfileSerializer, TokenSerializer
)


class UserRegisterView(generics.CreateAPIView):
    """
    POST /api/auth/register/
    Register a new user
    Request: {email, password, first_name, last_name}
    Response: {user, tokens}
    """
    permission_classes = [AllowAny]
    serializer_class = UserRegisterSerializer
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        user = serializer.save()
        
        # Generate tokens
        refresh = RefreshToken.for_user(user)
        
        response_data = {
            'user': UserSerializer(user).data,
            'tokens': {
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            }
        }
        
        return Response(response_data, status=status.HTTP_201_CREATED)


class UserLoginView(TokenObtainPairView):
    """
    POST /api/auth/login/
    Login user
    Request: {email, password}
    Response: {tokens, user}
    """
    permission_classes = [AllowAny]
    
    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        
        if response.status_code == 200:
            # Get user and add to response
            user = User.objects.get(email=request.data.get('email'))
            user.update_last_login()
            
            response.data['user'] = UserSerializer(user).data
        
        return response


class UserLogoutView(generics.GenericAPIView):
    """
    POST /api/auth/logout/
    Logout user (blacklist refresh token)
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        try:
            refresh_token = request.data.get('refresh')
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response({'detail': 'Successfully logged out'}, status=status.HTTP_205_RESET_CONTENT)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class UserMeView(generics.RetrieveUpdateAPIView):
    """
    GET /api/auth/me/
    Retrieve current user profile
    
    PUT /api/auth/me/
    Update current user profile
    """
    permission_classes = [IsAuthenticated]
    serializer_class = UserProfileSerializer
    
    def get_object(self):
        return self.request.user


class UserPreferencesUpdateView(generics.UpdateAPIView):
    """
    PATCH /api/auth/me/preferences/
    Update user medical specialization preferences
    Request: {primary_specialty_id, primary_exam_level_id, primary_subspecialty_id}
    """
    permission_classes = [IsAuthenticated]
    serializer_class = UserProfileSerializer
    
    def get_object(self):
        return self.request.user
    
    def partial_update(self, request, *args, **kwargs):
        user = self.get_object()
        
        # Update preferences
        if 'primary_specialty_id' in request.data:
            user.primary_specialty_id = request.data.get('primary_specialty_id')
        if 'primary_exam_level_id' in request.data:
            user.primary_exam_level_id = request.data.get('primary_exam_level_id')
        if 'primary_subspecialty_id' in request.data:
            user.primary_subspecialty_id = request.data.get('primary_subspecialty_id')
        
        user.save()
        return Response(UserProfileSerializer(user).data)