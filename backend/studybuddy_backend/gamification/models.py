# gamification/models.py

from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _

User = settings.AUTH_USER_MODEL

class VirtualCurrency(models.Model):
    """Model for tracking virtual currency balances."""
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='currency')
    balance = models.IntegerField(default=0)
    lifetime_earned = models.IntegerField(default=0)
    lifetime_spent = models.IntegerField(default=0)
    
    class Meta:
        verbose_name = 'Virtual Currency'
        verbose_name_plural = 'Virtual Currencies'
    
    def __str__(self):
        return f"{self.user} - {self.balance} points"
    
    def add_points(self, amount, transaction_type, description=""):
        """Add points to the user's balance and record the transaction."""
        if amount <= 0:
            raise ValueError("Amount must be positive")
            
        self.balance += amount
        self.lifetime_earned += amount
        self.save()
        
        # Record the transaction
        Transaction.objects.create(
            user=self.user,
            amount=amount,
            transaction_type=transaction_type,
            description=description,
            is_credit=True
        )
        
        return self.balance
    
    def deduct_points(self, amount, transaction_type, description=""):
        """Deduct points from the user's balance and record the transaction."""
        if amount <= 0:
            raise ValueError("Amount must be positive")
            
        if self.balance < amount:
            raise ValueError("Insufficient balance")
            
        self.balance -= amount
        self.lifetime_spent += amount
        self.save()
        
        # Record the transaction
        Transaction.objects.create(
            user=self.user,
            amount=amount,
            transaction_type=transaction_type,
            description=description,
            is_credit=False
        )
        
        return self.balance


class Transaction(models.Model):
    """Model for tracking point transactions."""
    
    TRANSACTION_TYPES = (
        ('session_completed', 'Session Completed'),
        ('feedback_given', 'Feedback Given'),
        ('achievement_unlocked', 'Achievement Unlocked'),
        ('reward_redeemed', 'Reward Redeemed'),
        ('bonus', 'Bonus Points'),
        ('other', 'Other'),
    )
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='transactions')
    amount = models.IntegerField()
    is_credit = models.BooleanField(default=True)  # True for earned points, False for spent points
    transaction_type = models.CharField(max_length=30, choices=TRANSACTION_TYPES)
    description = models.TextField(blank=True)
    timestamp = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'Transaction'
        verbose_name_plural = 'Transactions'
        ordering = ['-timestamp']
    
    def __str__(self):
        action = "earned" if self.is_credit else "spent"
        return f"{self.user} {action} {self.amount} points - {self.transaction_type}"


class Achievement(models.Model):
    """Model for achievements and badges."""
    
    # Achievement details
    name = models.CharField(max_length=100)
    description = models.TextField()
    icon = models.ImageField(upload_to='achievement_icons/')
    points_reward = models.IntegerField(default=0)
    
    # Achievement categories
    is_tutor_achievement = models.BooleanField(default=False)
    is_tutee_achievement = models.BooleanField(default=False)
    
    # Achievement criteria
    required_sessions = models.IntegerField(default=0)
    required_ratings = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    required_feedback_count = models.IntegerField(default=0)
    
    class Meta:
        verbose_name = 'Achievement'
        verbose_name_plural = 'Achievements'
    
    def __str__(self):
        return self.name


class UserAchievement(models.Model):
    """Model for tracking achievements earned by users."""
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='achievements')
    achievement = models.ForeignKey(Achievement, on_delete=models.CASCADE, related_name='earned_by')
    earned_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'User Achievement'
        verbose_name_plural = 'User Achievements'
        unique_together = ['user', 'achievement']
    
    def __str__(self):
        return f"{self.user} - {self.achievement.name}"


class Leaderboard(models.Model):
    """Model for leaderboard configurations."""
    
    PERIOD_CHOICES = (
        ('weekly', 'Weekly'),
        ('monthly', 'Monthly'),
        ('semester', 'Semester'),
        ('all_time', 'All Time'),
    )
    
    TYPE_CHOICES = (
        ('tutors', 'Tutors'),
        ('tutees', 'Tutees'),
        ('global', 'Global'),
    )
    
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    period = models.CharField(max_length=20, choices=PERIOD_CHOICES)
    leaderboard_type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    subject = models.ForeignKey('tutoring.Subject', on_delete=models.CASCADE, null=True, blank=True)
    
    # Active period
    start_date = models.DateField()
    end_date = models.DateField()
    
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'Leaderboard'
        verbose_name_plural = 'Leaderboards'
    
    def __str__(self):
        subject_str = f" - {self.subject}" if self.subject else ""
        return f"{self.name} ({self.period}{subject_str})"


class LeaderboardEntry(models.Model):
    """Model for entries in a leaderboard."""
    
    leaderboard = models.ForeignKey(Leaderboard, on_delete=models.CASCADE, related_name='entries')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='leaderboard_positions')
    points = models.IntegerField(default=0)
    rank = models.IntegerField()
    
    # Performance metrics
    sessions_completed = models.IntegerField(default=0)
    average_rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.0)
    achievements_count = models.IntegerField(default=0)
    
    # Timestamps
    last_updated = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Leaderboard Entry'
        verbose_name_plural = 'Leaderboard Entries'
        unique_together = ['leaderboard', 'user']
        ordering = ['rank']
    
    def __str__(self):
        return f"{self.leaderboard} - {self.user}: Rank {self.rank}"


class Reward(models.Model):
    """Model for rewards that can be redeemed with virtual currency."""
    
    name = models.CharField(max_length=100)
    description = models.TextField()
    image = models.ImageField(upload_to='reward_images/', null=True, blank=True)
    point_cost = models.IntegerField()
    
    # Reward details
    is_digital = models.BooleanField(default=True)
    is_featured = models.BooleanField(default=False)
    quantity_available = models.IntegerField(default=-1)  # -1 means unlimited
    
    # Validity period
    valid_from = models.DateField(null=True, blank=True)
    valid_until = models.DateField(null=True, blank=True)
    
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'Reward'
        verbose_name_plural = 'Rewards'
    
    def __str__(self):
        return f"{self.name} ({self.point_cost} points)"


class RedeemedReward(models.Model):
    """Model for tracking rewards redeemed by users."""
    
    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('fulfilled', 'Fulfilled'),
        ('cancelled', 'Cancelled'),
    )
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='redeemed_rewards')
    reward = models.ForeignKey(Reward, on_delete=models.CASCADE, related_name='redemptions')
    points_spent = models.IntegerField()
    redeemed_at = models.DateTimeField(auto_now_add=True)
    
    # Fulfillment details
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    fulfillment_date = models.DateTimeField(null=True, blank=True)
    fulfillment_notes = models.TextField(blank=True)
    
    class Meta:
        verbose_name = 'Redeemed Reward'
        verbose_name_plural = 'Redeemed Rewards'
        ordering = ['-redeemed_at']
    
    def __str__(self):
        return f"{self.user} - {self.reward.name} ({self.status})"