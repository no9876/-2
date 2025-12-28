USE master;
GO

-- 1. 如果数据库不存在则创建，存在则切换使用
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ArknightsSnowyMountainDB')
BEGIN
    CREATE DATABASE ArknightsSnowyMountainDB;
END
GO

USE ArknightsSnowyMountainDB;
GO

-- 2. 按外键依赖反向删除所有表（避免删除报错）
IF OBJECT_ID('PlayerActivityLevel', 'U') IS NOT NULL DROP TABLE PlayerActivityLevel;
IF OBJECT_ID('SignInActivity', 'U') IS NOT NULL DROP TABLE SignInActivity;
IF OBJECT_ID('BattleRecord', 'U') IS NOT NULL DROP TABLE BattleRecord;
IF OBJECT_ID('OperatorPromotion', 'U') IS NOT NULL DROP TABLE OperatorPromotion;
IF OBJECT_ID('OperatorSkill', 'U') IS NOT NULL DROP TABLE OperatorSkill;
IF OBJECT_ID('Operator', 'U') IS NOT NULL DROP TABLE Operator;
IF OBJECT_ID('Player', 'U') IS NOT NULL DROP TABLE Player;
IF OBJECT_ID('ActivityLevel', 'U') IS NOT NULL DROP TABLE ActivityLevel;
IF OBJECT_ID('Activity', 'U') IS NOT NULL DROP TABLE Activity;
GO

-- 3. 重建所有表结构（确保列名存在，解决207错误）
-- 3.1 活动主表
CREATE TABLE Activity (
    ActivityId INT NOT NULL PRIMARY KEY,
    ActivityName NVARCHAR(50) NOT NULL,
    ActivityType NVARCHAR(20) NOT NULL,  -- 解决"ActivityType无效"
    ActivityTask NVARCHAR(100) NOT NULL, -- 解决"ActivityTask无效"
    ActivityShop NVARCHAR(100) NOT NULL  -- 解决"ActivityShop无效"
);

-- 3.2 活动关卡表
CREATE TABLE ActivityLevel (
    ActivityLevelId INT NOT NULL PRIMARY KEY,
    ActivityId INT NOT NULL,
    ActivityLevelName NVARCHAR(50) NOT NULL, -- 解决"ActivityLevelName无效"
    StartTime DATETIME NOT NULL,             -- 解决"StartTime无效"
    EndTime DATETIME NOT NULL,               -- 解决"EndTime无效"
    CONSTRAINT FK_ActivityLevel_Activity FOREIGN KEY (ActivityId) REFERENCES Activity(ActivityId)
);

-- 3.3 玩家表
CREATE TABLE Player (
    PlayerId INT NOT NULL PRIMARY KEY,
    ActivityLevelId INT NOT NULL,
    Nickname NVARCHAR(30) NOT NULL,
    PlayerLevel INT NOT NULL,
    RegisterTime DATETIME NOT NULL,
    CONSTRAINT FK_Player_ActivityLevel FOREIGN KEY (ActivityLevelId) REFERENCES ActivityLevel(ActivityLevelId)
);

-- 3.4 干员表
CREATE TABLE Operator (
    OperatorId INT NOT NULL PRIMARY KEY,
    PlayerId INT NOT NULL,
    OperatorName NVARCHAR(30) NOT NULL,
    Rarity INT NOT NULL,
    IsActivity BIT NOT NULL,
    CONSTRAINT FK_Operator_Player FOREIGN KEY (PlayerId) REFERENCES Player(PlayerId)
);

-- 3.5 干员技能表
CREATE TABLE OperatorSkill (
    SkillId INT NOT NULL PRIMARY KEY,
    OperatorId INT NOT NULL,
    SkillName NVARCHAR(30) NOT NULL,
    SkillLevel INT NOT NULL,
    CONSTRAINT FK_OperatorSkill_Operator FOREIGN KEY (OperatorId) REFERENCES Operator(OperatorId)
);

-- 3.6 干员精英化表
CREATE TABLE OperatorPromotion (
    OperatorPromotionId INT NOT NULL PRIMARY KEY,
    OperatorId INT NOT NULL,
    PromotionLevel INT NOT NULL,
    UnlockTime DATE NOT NULL,
    CONSTRAINT FK_OperatorPromotion_Operator FOREIGN KEY (OperatorId) REFERENCES Operator(OperatorId)
);

-- 3.7 战斗记录表
CREATE TABLE BattleRecord (
    RecordId INT NOT NULL PRIMARY KEY,
    PlayerId INT NOT NULL,
    ActivityLevelId INT NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NOT NULL,
    Result NVARCHAR(10) NOT NULL,  -- 解决"Result无效"
    CONSTRAINT FK_BattleRecord_Player FOREIGN KEY (PlayerId) REFERENCES Player(PlayerId),
    CONSTRAINT FK_BattleRecord_ActivityLevel FOREIGN KEY (ActivityLevelId) REFERENCES ActivityLevel(ActivityLevelId)
);

-- 3.8 签到活动表
CREATE TABLE SignInActivity (
    SignInId INT NOT NULL PRIMARY KEY,
    ActivityId INT NOT NULL,
    PlayerId INT NOT NULL,
    SignInDate DATE NOT NULL,
    Reward NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_SignInActivity_Activity FOREIGN KEY (ActivityId) REFERENCES Activity(ActivityId),
    CONSTRAINT FK_SignInActivity_Player FOREIGN KEY (PlayerId) REFERENCES Player(PlayerId)
);

-- 3.9 玩家-关卡关联表
CREATE TABLE PlayerActivityLevel (
    PlayerActivityLevelId INT NOT NULL PRIMARY KEY, -- 解决"PlayerActivityLevelId无效"
    PlayerId INT NOT NULL,
    ActivityLevelId INT NOT NULL,
    CONSTRAINT FK_PlayerActivityLevel_Player FOREIGN KEY (PlayerId) REFERENCES Player(PlayerId),
    CONSTRAINT FK_PlayerActivityLevel_ActivityLevel FOREIGN KEY (ActivityLevelId) REFERENCES ActivityLevel(ActivityLevelId)
);
GO
