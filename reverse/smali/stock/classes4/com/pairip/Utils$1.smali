.class Lcom/pairip/Utils$1;
.super Ljava/lang/Object;
.source "Utils.java"

# interfaces
.implements Ljava/util/concurrent/ThreadFactory;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/pairip/Utils;->createThreadFactory(ZI)Ljava/util/concurrent/ThreadFactory;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$isDaemon:Z

.field final synthetic val$priority:I


# direct methods
.method constructor <init>(ZI)V
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x1010,
            0x1010
        }
        names = {
            "val$isDaemon",
            "val$priority"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    #@0
    .line 17
    iput-boolean p1, p0, Lcom/pairip/Utils$1;->val$isDaemon:Z

    #@2
    iput p2, p0, Lcom/pairip/Utils$1;->val$priority:I

    #@4
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@7
    return-void
.end method


# virtual methods
.method public newThread(Ljava/lang/Runnable;)Ljava/lang/Thread;
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "r"
        }
    .end annotation

    #@0
    .line 20
    new-instance v0, Ljava/lang/Thread;

    #@2
    invoke-direct {v0, p1}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V

    #@5
    .line 21
    iget-boolean p1, p0, Lcom/pairip/Utils$1;->val$isDaemon:Z

    #@7
    invoke-virtual {v0, p1}, Ljava/lang/Thread;->setDaemon(Z)V

    #@a
    .line 22
    iget p1, p0, Lcom/pairip/Utils$1;->val$priority:I

    #@c
    invoke-virtual {v0, p1}, Ljava/lang/Thread;->setPriority(I)V

    #@f
    return-object v0
.end method
